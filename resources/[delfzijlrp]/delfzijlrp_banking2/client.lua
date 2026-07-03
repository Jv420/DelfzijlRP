local function notify(message, type)
    lib.notify({ title = Config.Bank.name, description = message, type = type or 'inform' })
end

local function amountDialog(title)
    local input = lib.inputDialog(title, {
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = Config.Bank.transactionLimit }
    })
    return input and tonumber(input[1]) or nil
end

local function openTransactions(transactions)
    local options = {}
    for _, tx in ipairs(transactions or {}) do
        options[#options + 1] = {
            title = ('%s | €%s'):format(tx.type, tx.amount),
            description = ('%s | %s'):format(tx.counterparty_name or 'Geen tegenpartij', tx.description or ''),
            icon = 'receipt',
            readOnly = true
        }
    end

    if #options == 0 then
        options[#options + 1] = { title = 'Geen transacties', icon = 'circle-info', readOnly = true }
    end

    lib.registerContext({ id = 'delfzijlrp_banking2_transactions', title = 'Transacties', options = options })
    lib.showContext('delfzijlrp_banking2_transactions')
end

local function transferDialog()
    local input = lib.inputDialog('Overschrijven', {
        { type = 'input', label = 'IBAN ontvanger', required = true, min = 5, max = 34 },
        { type = 'number', label = 'Bedrag', required = true, min = 1, max = Config.Bank.transactionLimit },
        { type = 'input', label = 'Omschrijving', required = false, max = 255 }
    })
    if not input then return end
    TriggerServerEvent('delfzijlrp_banking2:server:transfer', input[1], input[2], input[3])
end

local function openBank()
    local overview = lib.callback.await('delfzijlrp_banking2:server:getOverview', false)
    if not overview then
        notify(Config.Text.accountNotFound, 'error')
        return
    end

    lib.registerContext({
        id = 'delfzijlrp_banking2_main',
        title = Config.Bank.name,
        options = {
            { title = overview.account_name or 'Mijn rekening', description = ('IBAN: %s'):format(overview.iban), icon = 'building-columns', readOnly = true },
            { title = 'Banksaldo', description = ('€%s'):format(overview.bank), icon = 'credit-card', readOnly = true },
            { title = 'Contant', description = ('€%s'):format(overview.cash), icon = 'money-bill', readOnly = true },
            { title = 'Geld storten', icon = 'money-bill-transfer', onSelect = function()
                local amount = amountDialog('Geld storten')
                if amount then TriggerServerEvent('delfzijlrp_banking2:server:deposit', amount) end
            end },
            { title = 'Geld opnemen', icon = 'money-bill-wave', onSelect = function()
                local amount = amountDialog('Geld opnemen')
                if amount then TriggerServerEvent('delfzijlrp_banking2:server:withdraw', amount) end
            end },
            { title = 'Overschrijven', description = ('Kosten: €%s'):format(Config.Bank.transferFee), icon = 'right-left', onSelect = transferDialog },
            { title = 'Transacties', icon = 'receipt', onSelect = function() openTransactions(overview.transactions) end }
        }
    })

    lib.showContext('delfzijlrp_banking2_main')
end

CreateThread(function()
    Wait(1500)

    for _, location in ipairs(Config.BankLocations) do
        if location.blip then
            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipColour(blip, location.blip.color)
            SetBlipScale(blip, location.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(location.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = location.coords,
            radius = 1.8,
            debug = Config.Debug,
            options = {{ name = 'banking2_bank', icon = 'fa-solid fa-building-columns', label = Config.Text.openBank, onSelect = openBank }}
        })
    end

    exports.ox_target:addModel(Config.ATMModels, {
        {
            name = 'banking2_atm',
            icon = 'fa-solid fa-credit-card',
            label = Config.Text.openATM,
            distance = 1.8,
            onSelect = openBank
        }
    })
end)

RegisterCommand(Config.Command, openBank, false)
RegisterCommand(Config.ATMCommand, openBank, false)
