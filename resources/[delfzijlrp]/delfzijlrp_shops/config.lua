Config = {}

Config.Debug = false
Config.UseBlips = true
Config.UsePeds = true

Config.PedModel = 'mp_m_shopkeep_01'

Config.Shops = {
    supermarket = {
        label = 'Supermarkt',
        icon = 'fa-solid fa-basket-shopping',
        blip = { sprite = 52, color = 2, scale = 0.75 },
        ped = Config.PedModel,
        locations = {
            vector4(24.47, -1346.62, 29.5, 271.66),
            vector4(-47.35, -1758.63, 29.42, 45.0),
            vector4(372.96, 328.03, 103.57, 255.0),
            vector4(1164.85, -323.67, 69.21, 100.0)
        },
        items = {
            { name = 'water', price = 8 },
            { name = 'bread', price = 10 },
            { name = 'phone', price = 650 },
            { name = 'radio', price = 750 },
            { name = 'bandage', price = 150 }
        }
    },

    gasstation = {
        label = 'Tankstation Winkel',
        icon = 'fa-solid fa-gas-pump',
        blip = { sprite = 361, color = 5, scale = 0.75 },
        ped = Config.PedModel,
        locations = {
            vector4(1164.12, -322.94, 69.21, 100.0),
            vector4(1697.87, 4923.39, 42.06, 325.0),
            vector4(1959.87, 3740.44, 32.34, 300.0)
        },
        items = {
            { name = 'water', price = 10 },
            { name = 'bread', price = 12 },
            { name = 'lighter', price = 25 },
            { name = 'phone', price = 700 },
            { name = 'radio', price = 800 }
        }
    },

    hardware = {
        label = 'Gereedschapswinkel',
        icon = 'fa-solid fa-screwdriver-wrench',
        blip = { sprite = 566, color = 47, scale = 0.75 },
        ped = 's_m_m_lathandy_01',
        locations = {
            vector4(2747.36, 3472.89, 55.67, 250.0),
            vector4(46.77, -1749.7, 29.63, 50.0)
        },
        items = {
            { name = 'lockpick', price = 350 },
            { name = 'repairkit', price = 750 },
            { name = 'toolbox', price = 1250 },
            { name = 'weapon_flashlight', price = 500 }
        }
    },

    anwb = {
        label = 'ANWB Onderdelen',
        icon = 'fa-solid fa-car-burst',
        blip = { sprite = 446, color = 46, scale = 0.75 },
        ped = 's_m_m_autoshop_01',
        job = 'mechanic',
        locations = {
            vector4(-347.23, -133.38, 39.01, 250.0)
        },
        items = {
            { name = 'repairkit', price = 250 },
            { name = 'advancedrepairkit', price = 900 },
            { name = 'cleaningkit', price = 150 },
            { name = 'carjack', price = 1200 }
        }
    },

    telecom = {
        label = 'Telefoonwinkel',
        icon = 'fa-solid fa-mobile-screen-button',
        blip = { sprite = 459, color = 3, scale = 0.75 },
        ped = 'a_m_y_business_02',
        locations = {
            vector4(-656.99, -857.06, 24.5, 0.0)
        },
        items = {
            { name = 'phone', price = 500 },
            { name = 'radio', price = 700 },
            { name = 'simcard', price = 75 }
        }
    }
}
