local insideProperty = nil

local function notify(message, type)
    lib.notify({ title = 'Kadaster Delfzijl', description = message, type = type or 'inform' })
end

local function teleport(coords)
    local ped = PlayerPedId()
    DoScreenFadeOut(350)
    Wait(450)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then SetEntityHeading(ped, coords.w) end
    Wait(350)
    DoScreenFadeIn(350)
end

local function openStorageMenu(property)
    local options = {}
    for stashType, stash in pairs(Config.StashTypes) do
        options[#options + 1] = {
            title = stash.label,
            description = ('Slots: %s | Gewicht: %skg'):format(stash.slots, math.floor(stash.weight / 1000)),
            icon = 'box-archive',
            onSelect = function() TriggerServerEvent('delfzijlrp_housing_v2:server:openStorage', property.id, stashType) end
        }
    end
    lib.registerContext({ id = 'delfzijlrp_housing_v2_storage', title = property.address .. ' opslag', options = options })
    lib.showContext('delfzijlrp_housing_v2_storage')
end

local function shareAccessDialog(property)
    local input = lib.inputDialog('Pandtoegang delen', {
        { type = 'number', label = 'Speler ID', required = true, min = 1 },
        { type = 'input', label = 'Type toegang', default = 'shared', required = true, min = 3, max = 32 }
    })
    if input then
        TriggerServerEvent('delfzijlrp_housing_v2:server:shareAccess', property.id, input[1], input[2])
    end
end

local function enterProperty(property)
    local data = lib.callback.await('delfzijlrp_housing_v2:server:getPropertyState', false, property.id)
    if not data or not data.access then notify(Config.Text.noAccess, 'error') return end
    insideProperty = property
    teleport(property.inside)
end

local function exitProperty()
    if not insideProperty then return end
    teleport(vector4(insideProperty.door.x, insideProperty.door.y, insideProperty.door.z, 0.0))
    insideProperty = nil
end

local function propertyStatusText(state)
    if not state then return 'Beschikbaar' end
    if state.status == 'owned' then return 'Verkocht' end
    if state.status == 'rented' then return 'Verhuurd tot ' .. (state.rent_until or 'onbekend') end
    return state.status or 'Beschikbaar'
end

local function openProperty(property)
    local data = lib.callback.await('delfzijlrp_housing_v2:server:getPropertyState', false, property.id)
    if not data then return end
    local state = data.state
    local tax = math.floor(property.price * (Config.Defaults.transferTaxPercent / 100))

    local options = {
        { title = property.address, description = property.postal .. ' | ' .. property.cadastral, icon = 'house', readOnly = true },
        { title = 'Type', description = Config.PropertyTypes[property.type] or property.type, icon = 'building', readOnly = true },
        { title = 'WOZ waarde', description = '€' .. property.woz, icon = 'chart-line', readOnly = true },
        { title = 'Bouwjaar', description = tostring(property.buildYear), icon = 'calendar', readOnly = true },
        { title = 'Status', description = propertyStatusText(state), icon = 'circle-info', readOnly = true }
    }

    if data.access then
        options[#options + 1] = { title = 'Naar binnen', icon = 'door-open', onSelect = function() enterProperty(property) end }
        options[#options + 1] = { title = 'Opslag beheren', icon = 'box-archive', onSelect = function() openStorageMenu(property) end }
        options[#options + 1] = { title = 'Toegang delen', icon = 'user-plus', onSelect = function() shareAccessDialog(property) end }
    else
        options[#options + 1] = { title = ('Kopen €%s + overdracht €%s'):format(property.price, tax), icon = 'file-signature', onSelect = function() TriggerServerEvent('delfzijlrp_housing_v2:server:buyProperty', property.id) end }
        options[#options + 1] = { title = ('Huren %s dagen voor €%s'):format(Config.Defaults.rentDays, property.rent), icon = 'file-contract', onSelect = function() TriggerServerEvent('delfzijlrp_housing_v2:server:rentProperty', property.id) end }
    end

    lib.registerContext({ id = 'delfzijlrp_housing_v2_property', title = property.address, options = options })
    lib.showContext('delfzijlrp_housing_v2_property')
end

local function openKadaster()
    local list = lib.callback.await('delfzijlrp_housing_v2:server:getProperties', false) or {}
    if #list == 0 then notify(Config.Text.noProperties, 'inform') return end

    local options = {}
    for _, row in ipairs(list) do
        local property = row.config
        local state = row.state
        options[#options + 1] = {
            title = property.address,
            description = ('%s | WOZ €%s | %s'):format(property.cadastral, property.woz, propertyStatusText(state)),
            icon = 'house',
            onSelect = function() openProperty(property) end
        }
    end

    lib.registerContext({ id = 'delfzijlrp_housing_v2_kadaster', title = Config.Office.label, options = options })
    lib.showContext('delfzijlrp_housing_v2_kadaster')
end

local function openMyProperties()
    local rows = lib.callback.await('delfzijlrp_housing_v2:server:getMyProperties', false) or {}
    if #rows == 0 then notify(Config.Text.noProperties, 'inform') return end

    local options = {}
    for _, row in ipairs(rows) do
        local property = nil
        for _, cfg in ipairs(Config.Properties) do
            if cfg.id == row.property_id then property = cfg break end
        end
        if property then
            options[#options + 1] = {
                title = property.address,
                description = ('%s | %s'):format(property.cadastral, propertyStatusText(row)),
                icon = 'house-user',
                onSelect = function() openProperty(property) end
            }
        end
    end

    lib.registerContext({ id = 'delfzijlrp_housing_v2_my', title = 'Mijn panden', options = options })
    lib.showContext('delfzijlrp_housing_v2_my')
end

CreateThread(function()
    Wait(1500)

    if Config.Office.blip then
        local blip = AddBlipForCoord(Config.Office.coords.x, Config.Office.coords.y, Config.Office.coords.z)
        SetBlipSprite(blip, Config.Office.blip.sprite)
        SetBlipColour(blip, Config.Office.blip.color)
        SetBlipScale(blip, Config.Office.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Office.label)
        EndTextCommandSetBlipName(blip)
    end

    exports.ox_target:addSphereZone({
        coords = Config.Office.coords,
        radius = Config.Office.radius,
        debug = Config.Debug,
        options = {{ name = 'kadaster_office', icon = 'fa-solid fa-building-columns', label = Config.Text.openOffice, onSelect = openKadaster }}
    })

    for _, property in ipairs(Config.Properties) do
        if property.blip then
            local blip = AddBlipForCoord(property.door.x, property.door.y, property.door.z)
            SetBlipSprite(blip, property.blip.sprite)
            SetBlipColour(blip, property.blip.color)
            SetBlipScale(blip, property.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(property.address)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = property.door,
            radius = 1.6,
            debug = Config.Debug,
            options = {{ name = 'kadaster_property_' .. property.id, icon = 'fa-solid fa-house', label = Config.Text.openProperty, onSelect = function() openProperty(property) end }}
        })

        exports.ox_target:addSphereZone({
            coords = property.exit,
            radius = 1.5,
            debug = Config.Debug,
            options = {{ name = 'kadaster_exit_' .. property.id, icon = 'fa-solid fa-door-open', label = Config.Text.exitProperty, onSelect = exitProperty }}
        })

        for stashType, coords in pairs(property.stashes or {}) do
            exports.ox_target:addSphereZone({
                coords = coords,
                radius = 1.3,
                debug = Config.Debug,
                options = {{ name = 'kadaster_storage_' .. property.id .. '_' .. stashType, icon = 'fa-solid fa-box-archive', label = Config.StashTypes[stashType] and Config.StashTypes[stashType].label or 'Opslag', onSelect = function() TriggerServerEvent('delfzijlrp_housing_v2:server:openStorage', property.id, stashType) end }}
            })
        end
    end
end)

RegisterCommand(Config.Command, openKadaster, false)
RegisterCommand(Config.HouseCommand, openMyProperties, false)

RegisterNetEvent('delfzijlrp_housing_v2:client:openStorage', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
