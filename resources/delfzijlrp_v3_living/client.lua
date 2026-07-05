local function msg(text, kind)
    lib.notify({ title = 'Living Netherlands', description = text, type = kind or 'inform' })
end

local function setWaypoint(coords)
    SetNewWaypoint(coords.x, coords.y)
    msg(Config.Text.waypoint, 'success')
end

local function runCommand(command)
    if command and command ~= '' then
        ExecuteCommand(command)
    end
end

local function openDistrict(district)
    local options = {
        { title = 'Waypoint zetten', description = district.label, onSelect = function() setWaypoint(district.coords) end }
    }

    for _, task in ipairs(district.tasks or {}) do
        options[#options + 1] = {
            title = task.label,
            description = 'Dagtaak beloning: €' .. (task.reward or 0),
            onSelect = function()
                local ok, text = lib.callback.await('delfzijlrp_v3_living:server:completeTask', false, task.id)
                msg(text or Config.Text.noTask, ok and 'success' or 'error')
                if ok and task.command then runCommand(task.command) end
            end
        }
    end

    lib.registerContext({ id = 'living_district_' .. district.id, title = district.label, menu = 'living_main', options = options })
    lib.showContext('living_district_' .. district.id)
end

local function openEvents()
    local options = {}
    for _, event in ipairs(Config.Events) do
        options[#options + 1] = {
            title = event.label,
            description = event.description,
            readOnly = true
        }
    end
    lib.registerContext({ id = 'living_events', title = 'Stadsevenementen', menu = 'living_main', options = options })
    lib.showContext('living_events')
end

local function openMain()
    local options = {}
    for _, district in ipairs(Config.Districts) do
        options[#options + 1] = {
            title = district.label,
            description = 'Taken, locaties en stadsleven',
            onSelect = function() openDistrict(district) end
        }
    end
    options[#options + 1] = { title = 'Stadsevenementen', description = 'Markt, kermis, DelfSail en meer', onSelect = openEvents }

    lib.registerContext({ id = 'living_main', title = Config.City.name .. ' - ' .. Config.City.slogan, options = options })
    lib.showContext('living_main')
end

CreateThread(function()
    Wait(1500)
    for i, district in ipairs(Config.Districts) do
        if district.blip then
            local blip = AddBlipForCoord(district.coords.x, district.coords.y, district.coords.z)
            SetBlipSprite(blip, district.blip.sprite)
            SetBlipColour(blip, district.blip.color)
            SetBlipScale(blip, district.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(district.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = district.coords,
            radius = 2.0,
            debug = Config.Debug,
            options = {{ name = 'living_district_' .. i, label = district.label, onSelect = function() openDistrict(district) end }}
        })
    end
end)

RegisterCommand(Config.Command, openMain, false)
RegisterNetEvent('delfzijlrp_v3_living:client:openDaily', openMain)
