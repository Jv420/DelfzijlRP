local ESX = exports['es_extended']:getSharedObject()

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function getIdentifier(source)
    local xPlayer = getPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

local function notify(source, message, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = Config.Bank.name,
        description = message,
        type = type or 'inform'
    })
end

local function getIdentityName(identifier, fallback)
    local identity = MySQL.single.await('SELECT firstname, lastname FROM delfzijlrp_identities WHERE identifier = ? LIMIT 1', { identifier })
    if identity then return identity.firstname .. ' ' .. identity.lastname end
    return fallback
end

local function randomDigits(length)
    local value = ''
    for _ = 1, length do value = value .. tostring(math.random(0, 9)) end
    return value
end

local function createIban()
    local iban
    repeat
        iban = ('%s%s%s'):format(Config.Bank.ibanPrefix, os.date('%y'), randomDigits(10))
    until not MySQL.scalar.await('SELECT iban FROM delfzijlrp_bank_accounts WHERE iban = ? LIMIT 1', { iban })
    return iban
end

local function logTransaction(identifier, iban, txType, amount, counterpartyIban, counterpartyName, description)
    MySQL.insert.await([[INSERT INTO delfzijlrp_bank_transactions
        (identifier, iban, type, amount, counterparty_iban, counterparty_name, description)
        VALUES (?, ?, ?, ?, ?, ?, ?)]], {
        identifier,
        iban,
        txType,
        amount,
        counterpartyIban,
        counterpartyName,
        description
    })
end

local function ensureAccount(source)
    local identifier = getIdentifier(source)
    if not identifier then return nil end

    local account = MySQL.single.await('SELECT * FROM delfzijlrp_bank_accounts WHERE identifier = ? LIMIT 1', { identifier })
    if account then return account end

    local iban = createIban()
    local name = getIdentityName(identifier, GetPlayerName(source))
    MySQL.insert.await('INSERT INTO delfzijlrp_bank_accounts (identifier, iban, account_name) VALUES (?, ?, ?)', {
        identifier,
        iban,
        name
    })

    notify(source, Config.Text.accountCreated, 'success')
    return { identifier = identifier, iban = iban, account_name = name }
end

exports('GetBankAccount', function(source)
    return ensureAccount(source)
end)

exports('LogTransaction', function(identifier, iban, txType, amount, counterpartyIban, counterpartyName, description)
    logTransaction(identifier, iban, txType, amount, counterpartyIban, counterpartyName, description)
end)

lib.callback.register('delfzijlrp_banking2:server:getOverview', function(source)
    local xPlayer = getPlayer(source)
    local account = ensureAccount(source)
    if not xPlayer or not account then return nil end

    local transactions = MySQL.query.await('SELECT * FROM delfzijlrp_bank_transactions WHERE identifier = ? ORDER BY created_at DESC LIMIT 20', {
        xPlayer.identifier
    }) or {}

    return {
        iban = account.iban,
        account_name = account.account_name,
        cash = xPlayer.getMoney(),
        bank = xPlayer.getAccount('bank').money,
        transactions = transactions
    }
end)

RegisterNetEvent('delfzijlrp_banking2:server:deposit', function(amount)
    local source = source
    local xPlayer = getPlayer(source)
    local account = ensureAccount(source)
    amount = tonumber(amount) or 0

    if not xPlayer or not account or amount <= 0 then return end
    if amount > Config.Bank.transactionLimit then
        notify(source, Config.Text.limitExceeded, 'error')
        return
    end
    if xPlayer.getMoney() < amount then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    xPlayer.removeMoney(amount)
    xPlayer.addAccountMoney('bank', amount)
    logTransaction(xPlayer.identifier, account.iban, 'deposit', amount, nil, nil, 'Contant gestort')
    notify(source, Config.Text.depositDone, 'success')
end)

RegisterNetEvent('delfzijlrp_banking2:server:withdraw', function(amount)
    local source = source
    local xPlayer = getPlayer(source)
    local account = ensureAccount(source)
    amount = tonumber(amount) or 0

    if not xPlayer or not account or amount <= 0 then return end
    if amount > Config.Bank.transactionLimit then
        notify(source, Config.Text.limitExceeded, 'error')
        return
    end
    if xPlayer.getAccount('bank').money < amount then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    xPlayer.removeAccountMoney('bank', amount)
    xPlayer.addMoney(amount)
    logTransaction(xPlayer.identifier, account.iban, 'withdraw', amount, nil, nil, 'Contant opgenomen')
    notify(source, Config.Text.withdrawDone, 'success')
end)

RegisterNetEvent('delfzijlrp_banking2:server:transfer', function(targetIban, amount, description)
    local source = source
    local xPlayer = getPlayer(source)
    local account = ensureAccount(source)
    amount = tonumber(amount) or 0
    targetIban = tostring(targetIban or ''):upper()

    if not xPlayer or not account or amount <= 0 or #targetIban < 5 then
        notify(source, Config.Text.invalidInput, 'error')
        return
    end

    if amount > Config.Bank.transactionLimit then
        notify(source, Config.Text.limitExceeded, 'error')
        return
    end

    local total = amount + Config.Bank.transferFee
    if xPlayer.getAccount('bank').money < total then
        notify(source, Config.Text.noMoney, 'error')
        return
    end

    local targetAccount = MySQL.single.await('SELECT * FROM delfzijlrp_bank_accounts WHERE iban = ? LIMIT 1', { targetIban })
    if not targetAccount then
        notify(source, Config.Text.accountNotFound, 'error')
        return
    end

    xPlayer.removeAccountMoney('bank', total)
    logTransaction(xPlayer.identifier, account.iban, 'transfer_out', amount, targetIban, targetAccount.account_name, description or 'Overschrijving')
    logTransaction(xPlayer.identifier, account.iban, 'fee', Config.Bank.transferFee, nil, 'Delfzijl Bank', 'Transactiekosten')

    for _, targetPlayer in pairs(ESX.GetExtendedPlayers()) do
        if targetPlayer.identifier == targetAccount.identifier then
            targetPlayer.addAccountMoney('bank', amount)
            notify(targetPlayer.source, ('Nieuwe overschrijving ontvangen: €%s'):format(amount), 'success')
            break
        end
    end

    logTransaction(targetAccount.identifier, targetIban, 'transfer_in', amount, account.iban, account.account_name, description or 'Overschrijving')
    notify(source, Config.Text.transferDone, 'success')
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    if Config.CreateAccountOnJoin then
        ensureAccount(playerId)
    end
end)
