local function openReviews(restId)
    local rows = lib.callback.await('delfzijlrp_v3_restaurants:server:getReviews', false, restId) or {}
    local opts = {
        { title = 'Review schrijven', description = 'Geef sterren en tekst', onSelect = function()
            local input = lib.inputDialog('Review', {
                { type = 'number', label = 'Rating 1-5', required = true, min = 1, max = 5, default = 5 },
                { type = 'input', label = 'Tekst', required = false }
            })
            if input then TriggerServerEvent('delfzijlrp_v3_restaurants:server:review', restId, input[1], input[2]) end
        end }
    }
    for _, r in ipairs(rows) do
        opts[#opts + 1] = { title = r.player_name .. ' - ' .. tostring(r.rating) .. '/5', description = r.text or '', readOnly = true }
    end
    lib.registerContext({ id = 'restaurant_reviews_' .. restId, title = 'Reviews', menu = 'restaurant_' .. restId, options = opts })
    lib.showContext('restaurant_reviews_' .. restId)
end

local function openRestaurant(restId)
    local rest = Config.Restaurants[restId]
    if not rest then return end
    local opts = {}
    for _, p in ipairs(rest.menu or {}) do
        opts[#opts + 1] = {
            title = p.label,
            description = '€' .. p.price,
            onSelect = function()
                local input = lib.inputDialog(p.label, {
                    { type = 'number', label = 'Aantal', required = true, min = 1, default = 1 }
                })
                if input then TriggerServerEvent('delfzijlrp_v3_restaurants:server:buy', restId, p.item, input[1]) end
            end
        }
    end
    opts[#opts + 1] = { title = 'Reviews', description = 'Bekijk of schrijf een review', onSelect = function() openReviews(restId) end }
    lib.registerContext({ id = 'restaurant_' .. restId, title = rest.label, options = opts })
    lib.showContext('restaurant_' .. restId)
end

local function openList()
    local opts = {}
    for id, rest in pairs(Config.Restaurants) do
        opts[#opts + 1] = { title = rest.label, description = 'Menu openen', onSelect = function() openRestaurant(id) end }
    end
    lib.registerContext({ id = 'restaurant_list', title = 'Restaurants', options = opts })
    lib.showContext('restaurant_list')
end

local function openKitchen(restId)
    local rows = lib.callback.await('delfzijlrp_v3_restaurants:server:getOrders', false, restId or '') or {}
    local opts = {}
    for _, o in ipairs(rows) do
        opts[#opts + 1] = {
            title = '#' .. o.id .. ' ' .. o.label .. ' x' .. tostring(o.amount),
            description = o.restaurant_id .. ' | ' .. o.player_name .. ' | ' .. o.status,
            onSelect = function()
                lib.registerContext({
                    id = 'restaurant_order_' .. o.id,
                    title = 'Order #' .. o.id,
                    menu = 'restaurant_kitchen',
                    options = {
                        { title = 'In bereiding zetten', onSelect = function() TriggerServerEvent('delfzijlrp_v3_restaurants:server:setOrderStatus', o.id, 'preparing') end },
                        { title = 'Klaar zetten', onSelect = function() TriggerServerEvent('delfzijlrp_v3_restaurants:server:setOrderStatus', o.id, 'ready') end },
                        { title = 'Bezorgd/afgegeven', onSelect = function() TriggerServerEvent('delfzijlrp_v3_restaurants:server:setOrderStatus', o.id, 'delivered') end }
                    }
                })
                lib.showContext('restaurant_order_' .. o.id)
            end
        }
    end
    if #opts == 0 then opts[1] = { title = 'Geen openstaande bestellingen', readOnly = true } end
    lib.registerContext({ id = 'restaurant_kitchen', title = 'Keukenscherm', options = opts })
    lib.showContext('restaurant_kitchen')
end

CreateThread(function()
    Wait(1500)
    for id, rest in pairs(Config.Restaurants) do
        if rest.blip then
            local b = AddBlipForCoord(rest.coords.x, rest.coords.y, rest.coords.z)
            SetBlipSprite(b, rest.blip.sprite)
            SetBlipColour(b, rest.blip.color)
            SetBlipScale(b, rest.blip.scale)
            SetBlipAsShortRange(b, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(rest.label)
            EndTextCommandSetBlipName(b)
        end
        exports.ox_target:addSphereZone({
            coords = rest.coords,
            radius = rest.radius or 2.0,
            debug = Config.Debug,
            options = {
                { name = 'rest_' .. id, label = Config.Text.open .. ' - ' .. rest.label, onSelect = function() openRestaurant(id) end },
                { name = 'rest_kitchen_' .. id, label = Config.Text.kitchen .. ' - ' .. rest.label, onSelect = function() openKitchen(id) end }
            }
        })
    end
end)

RegisterCommand(Config.Command, openList, false)
RegisterCommand(Config.KitchenCommand, function()
    local input = lib.inputDialog('Keukenscherm', {
        { type = 'input', label = 'Restaurant ID leeg = alles', required = false }
    })
    openKitchen(input and input[1] or '')
end, false)
