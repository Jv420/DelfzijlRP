local function notify(description, type)
    lib.notify({
        title = 'Delfzijl RP Bank',
        description = description,
        type = type or 'inform'
    })
end

local function formatMoney(amount)
    return ('%s%s'):format(Config.Currency, ESX.Math.GroupDigits(amount or 0))
end

local function getAmountDialog(title)
    local input = lib.inputDialog(title, {
        {
            type = 'number',
            label = 'Bedrag',
            min = Config.Limits.minAmount,
            required = true
        }
    })

    if not input then return nil end
    return tonumber(input[1])
end

local function getTransferDialog()
    local input = lib.inputDialog('Geld overmaken', {
        {
            type = 'number',
            label = 'Speler ID',
            min = 1,
            required = true
        },
        {
            type = 'number',
            label = 'Bedrag',
            min = Config.Limits.minAmount,
            required = true
        }
    })

    if not input then return nil end
    return tonumber(input[1]), tonumber(input[2])
end

local function openBankMenu()
    local data = lib.callback.await('delfzijlrp_banking:server:getBalance', false)
    if not data then return end

    lib.registerContext({
        id = 'delfzijlrp_bank_main',
        title = 'Delfzijl RP Bank',
        options = {
            {
                title = 'Saldo',
                description = ('Contant: %s | Bank: %s'):format(formatMoney(data.cash), formatMoney(data.bank)),
                icon = 'wallet',
                readOnly = true
            },
            {
                title = 'Geld storten',
                icon = 'money-bill-transfer',
                onSelect = function()
                    local amount = getAmountDialog('Geld storten')
                    if amount then
                        TriggerServerEvent('delfzijlrp_banking:server:deposit', amount)
                    end
                end
            },
            {
                title = 'Geld opnemen',
                icon = 'money-bill-wave',
                onSelect = function()
                    local amount = getAmountDialog('Geld opnemen')
                    if amount then
                        TriggerServerEvent('delfzijlrp_banking:server:withdraw', amount)
                    end
                end
            },
            {
                title = 'Geld overmaken',
                icon = 'building-columns',
                onSelect = function()
                    local targetId, amount = getTransferDialog()
                    if targetId and amount then
                        TriggerServerEvent('delfzijlrp_banking:server:transfer', targetId, amount)
                    end
                end
            }
        }
    })

    lib.showContext('delfzijlrp_bank_main')
end

CreateThread(function()
    while not ESX do
        ESX = exports['es_extended']:getSharedObject()
        Wait(250)
    end
end)

CreateThread(function()
    Wait(1500)

    for index, coords in ipairs(Config.Banks) do
        if Config.UseBlips then
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(blip, 108)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.75)
            SetBlipColour(blip, 2)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString('Bank')
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = coords,
            radius = 1.5,
            debug = Config.Debug,
            options = {
                {
                    name = ('delfzijlrp_bank_%s'):format(index),
                    icon = 'fa-solid fa-building-columns',
                    label = Config.Text.bank,
                    distance = 2.0,
                    onSelect = openBankMenu
                }
            }
        })
    end

    exports.ox_target:addModel(Config.ATMModels, {
        {
            name = 'delfzijlrp_atm_open',
            icon = 'fa-solid fa-credit-card',
            label = Config.Text.atm,
            distance = 1.5,
            onSelect = openBankMenu
        }
    })
end)

RegisterNetEvent('delfzijlrp_banking:client:notify', function(message, type)
    notify(message, type)
end)
