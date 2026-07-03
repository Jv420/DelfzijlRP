local insideHouse = nil

local function notify(message, type)
    lib.notify({ title = 'Delfzijl RP Housing', description = message, type = type or 'inform' })
end

local function teleport(coords)
    local ped = PlayerPedId()
    DoScreenFadeOut(400)
    Wait(500)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then SetEntityHeading(ped, coords.w) end
    Wait(500)
    DoScreenFadeIn(400)
end

local function enterHouse(house)
    local data = lib.callback.await('delfzijlrp_housing:server:getHouseState', false, house.id)
    if not data or not data.access then
        notify(Config.Text.noAccess, 'error')
        return
    end

    insideHouse = house
    teleport(house.inside)
end

local function exitHouse()
    if not insideHouse then return end
    teleport(vector4(insideHouse.door.x, insideHouse.door.y, insideHouse.door.z, 0.0))
    insideHouse = nil
end

local function giveKeyDialog(house)
    local input = lib.inputDialog('Woning sleutel geven', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 }
    })

    if input then
        TriggerServerEvent('delfzijlrp_housing:server:giveKey', house.id, input[1])
    end
end

local function openHouseMenu(house)
    local data = lib.callback.await('delfzijlrp_housing:server:getHouseState', false, house.id)
    local state = data and data.state or nil
    local status = Config.Text.available

    if state and state.owned == 1 then
        status = 'Gekocht'
    elseif state and state.rented == 1 then
        status = 'Verhuurd tot ' .. (state.rent_until or 'onbekend')
    end

    local options = {
        { title = house.label, description = ('Status: %s'):format(status), icon = 'house', readOnly = true }
    }

    if data and data.access then
        options[#options + 1] = { title = 'Naar binnen', icon = 'door-open', onSelect = function() enterHouse(house) end }
        options[#options + 1] = { title = 'Sleutel geven', icon = 'key', onSelect = function() giveKeyDialog(house) end }
    else
        options[#options + 1] = { title = ('Kopen (€%s)'):format(house.price), icon = 'sack-dollar', onSelect = function() TriggerServerEvent('delfzijlrp_housing:server:buyHouse', house.id) end }
        options[#options + 1] = { title = ('Huren voor %s dagen (€%s)'):format(Config.RentDays, house.rent), icon = 'file-contract', onSelect = function() TriggerServerEvent('delfzijlrp_housing:server:rentHouse', house.id) end }
    end

    lib.registerContext({ id = 'delfzijlrp_house_menu', title = house.label, options = options })
    lib.showContext('delfzijlrp_house_menu')
end

local function openMyHouses()
    local houses = lib.callback.await('delfzijlrp_housing:server:getMyHouses', false) or {}
    if #houses == 0 then
        notify('Je hebt geen woningen of sleutels.', 'inform')
        return
    end

    local options = {}
    for _, row in ipairs(houses) do
        local label = row.house_id
        for _, house in ipairs(Config.Houses) do
            if house.id == row.house_id then label = house.label end
        end

        options[#options + 1] = {
            title = label,
            description = row.owned == 1 and 'Eigenaar' or 'Toegang/huur',
            icon = 'house',
            readOnly = true
        }
    end

    lib.registerContext({ id = 'delfzijlrp_my_houses', title = 'Mijn woningen', options = options })
    lib.showContext('delfzijlrp_my_houses')
end

CreateThread(function()
    Wait(1500)

    for _, house in ipairs(Config.Houses) do
        if Config.UseBlips and house.blip then
            local blip = AddBlipForCoord(house.door.x, house.door.y, house.door.z)
            SetBlipSprite(blip, house.blip.sprite)
            SetBlipColour(blip, house.blip.color)
            SetBlipScale(blip, house.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(house.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = house.door,
            radius = 1.5,
            debug = Config.Debug,
            options = {
                {
                    name = 'house_door_' .. house.id,
                    icon = 'fa-solid fa-house',
                    label = Config.Text.openHouse,
                    distance = 2.0,
                    onSelect = function() openHouseMenu(house) end
                }
            }
        })

        exports.ox_target:addSphereZone({
            coords = house.exit,
            radius = 1.5,
            debug = Config.Debug,
            options = {
                {
                    name = 'house_exit_' .. house.id,
                    icon = 'fa-solid fa-door-open',
                    label = Config.Text.exitHouse,
                    distance = 2.0,
                    onSelect = exitHouse
                }
            }
        })

        exports.ox_target:addSphereZone({
            coords = house.stash,
            radius = 1.5,
            debug = Config.Debug,
            options = {
                {
                    name = 'house_stash_' .. house.id,
                    icon = 'fa-solid fa-box-archive',
                    label = Config.Text.openStash,
                    distance = 2.0,
                    onSelect = function()
                        TriggerServerEvent('delfzijlrp_housing:server:openStash', house.id)
                    end
                }
            }
        })
    end
end)

RegisterCommand(Config.Command, openMyHouses, false)

RegisterNetEvent('delfzijlrp_housing:client:openStash', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
