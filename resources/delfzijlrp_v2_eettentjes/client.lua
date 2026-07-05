local function msg(text, kind)
    lib.notify({ title = 'Delfzijl Eettentjes', description = text, type = kind or 'inform' })
end

local function openStand(stand)
    local options = {}
    for _, item in ipairs(stand.items or {}) do
        options[#options + 1] = {
            title = item.label,
            description = 'Prijs: €' .. item.price,
            onSelect = function()
                local input = lib.inputDialog(item.label, {
                    { type = 'number', label = 'Aantal', default = 1, required = true, min = 1, max = Config.Extras.maxAmount },
                    { type = 'number', label = 'Fooi', default = 0, required = false, min = 0, max = 500 }
                })
                if not input then return end
                local ok, text = lib.callback.await('delfzijlrp_v2_eettentjes:server:buy', false, stand.id, item.name, input[1], input[2])
                msg(text or Config.Text.invalid, ok and 'success' or 'error')
            end
        }
    end
    lib.registerContext({ id = 'drp_food_' .. stand.id, title = stand.label, options = options })
    lib.showContext('drp_food_' .. stand.id)
end

local function openAll()
    local options = {}
    for _, stand in ipairs(Config.Stands) do
        options[#options + 1] = {
            title = stand.label,
            description = 'Bekijk menu',
            onSelect = function() openStand(stand) end
        }
    end
    lib.registerContext({ id = 'drp_food_main', title = 'Delfzijl Food Court', options = options })
    lib.showContext('drp_food_main')
end

CreateThread(function()
    Wait(1500)
    for i, stand in ipairs(Config.Stands) do
        if stand.blip then
            local blip = AddBlipForCoord(stand.coords.x, stand.coords.y, stand.coords.z)
            SetBlipSprite(blip, stand.blip.sprite)
            SetBlipColour(blip, stand.blip.color)
            SetBlipScale(blip, stand.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(stand.label)
            EndTextCommandSetBlipName(blip)
        end

        exports.ox_target:addSphereZone({
            coords = stand.coords,
            radius = stand.radius,
            debug = Config.Debug,
            options = {{ name = 'drp_food_' .. i, label = stand.label, onSelect = function() openStand(stand) end }}
        })
    end
end)

RegisterCommand(Config.Command, openAll, false)
