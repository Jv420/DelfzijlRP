Config = {}

Config.Debug = false
Config.RequiredPolice = 0
Config.DispatchChance = 75
Config.GlobalCooldown = 300

Config.Tools = {
    basic = 'lockpick',
    advanced = 'advancedlockpick'
}

Config.Incidents = {
    shop = {
        label = 'Winkelincident',
        requiredTool = 'lockpick',
        duration = 9000,
        cooldown = 1800,
        dispatchType = 'emergency',
        reward = { account = 'black_money', min = 1200, max = 3500 },
        locations = {
            { id = 'shop_vespucci', coords = vector3(-47.14, -1758.83, 29.42), radius = 1.8 },
            { id = 'shop_sandy', coords = vector3(1961.22, 3749.32, 32.34), radius = 1.8 },
            { id = 'shop_paleto', coords = vector3(1734.84, 6420.84, 35.04), radius = 1.8 }
        }
    },
    atm = {
        label = 'ATM incident',
        requiredTool = 'drill',
        duration = 12000,
        cooldown = 2400,
        dispatchType = 'emergency',
        reward = { account = 'black_money', min = 800, max = 2200 },
        models = {
            `prop_atm_01`,
            `prop_atm_02`,
            `prop_atm_03`,
            `prop_fleeca_atm`
        }
    },
    container = {
        label = 'Havencontainer incident',
        requiredTool = 'advancedlockpick',
        duration = 14000,
        cooldown = 2700,
        dispatchType = 'emergency',
        rewardItems = {
            { item = 'electronics', min = 1, max = 3 },
            { item = 'tools', min = 1, max = 2 }
        },
        locations = {
            { id = 'container_haven_1', coords = vector3(1208.22, -3115.64, 5.54), radius = 2.0 },
            { id = 'container_haven_2', coords = vector3(1232.42, -3098.31, 5.54), radius = 2.0 }
        }
    }
}

Config.Text = {
    noTool = 'Je mist het benodigde item.',
    notEnoughPolice = 'Er is momenteel te weinig politie in dienst.',
    cooldown = 'Deze locatie is recent al gebruikt.',
    cancelled = 'Actie geannuleerd.',
    success = 'Actie voltooid.',
    dispatch = 'Verdachte situatie gemeld.',
    failed = 'Het is mislukt.'
}
