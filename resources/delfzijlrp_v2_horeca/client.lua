local function msg(text, kind)
    lib.notify({ title = 'Delfzijl Horeca', description = text, type = kind or 'inform' })
end

local function openPlace(place)
    local options = {}
    for _, item in ipairs(place.items or {}) do
        options[#options + 1] = {
            title = item.label,
            description = 'Prijs: €' .. item.price,
            onSelect = function()
                local input = lib.inputDialog(item.label, {
                    { type = 'number', label = 'Aantal', default = 1, required = true, min = 1, max = Config.Settings.maxAmount },
                    { type = 'number', label = 'Fooi', default = 0, required = false, min = 0, max = Config.Settings.maxTip }
                })
                if not input then return end
                local ok, text = lib.callback.await('delfzijlrp_v2_horeca:server:buy', false, place.id, item.name, input[1], input[2])
                msg(text or Config.Text.invalid, ok and 'success' or 'error')
            end
        }
    end
    lib.registerContext({ id = 'drp_horeca_' .. place.id, title = place.label, options = options })
    lib.showContext('drp_horeca_' .. place.id)
end

local function openAll()
    local options = {}
    for _, place in ipairs(Config.Places) do
        options[#options + 1] = {
            title = place.label,
            description = 'Bekijk kaart',
            onSelect = function() openPlace(place) end
        }
    end
    lib.registerContext({ id = 'drp_horeca_main', title = 'Delfzijl Horeca', options = options })
    lib.showContext('drp_horeca_main')
end

CreateThread(function()
    Wait(1500)
    for i, place in ipairs(Config.Places) do
        if place.blip then
            local blip = AddBlipForCoord(place.coords.x, place.coords.y, place.coords.z)
            SetBlipSprite(blip, place.blip.sprite)
            SetBlipColour(blip, place.blip.color)
            SetBlipScale(blip, place.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(place.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = place.coords,
            radius = place.radius,
            debug = Config.Debug,
            options = {{ name = 'drp_horeca_' .. i, label = place.label, onSelect = function() openPlace(place) end }}
        })
    end
end)

RegisterCommand(Config.Command, openAll, false)
