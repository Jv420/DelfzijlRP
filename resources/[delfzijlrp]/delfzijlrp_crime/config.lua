Config = {}

Config.Debug = false

Config.BlackMarket = {
    enabled = true,
    label = 'Zwarte Markt',
    ped = 'g_m_m_chicold_01',
    icon = 'fa-solid fa-user-secret',
    location = vector4(706.72, -966.97, 30.41, 93.0),
    blip = false,
    items = {
        { name = 'lockpick', price = 450 },
        { name = 'advancedlockpick', price = 1250 },
        { name = 'drill', price = 2500 },
        { name = 'thermite', price = 4000 },
        { name = 'repairkit', price = 900 },
        { name = 'black_phone', price = 1500 }
    }
}

Config.VehicleTheft = {
    enabled = true,
    requiredItem = 'lockpick',
    advancedItem = 'advancedlockpick',
    consumeChance = 35,
    policeAlertChance = 35,
    searchDuration = 6500,
    minPolice = 0,
    rewards = {
        { name = 'money', min = 50, max = 300, chance = 60 },
        { name = 'radio', min = 1, max = 1, chance = 10 },
        { name = 'phone', min = 1, max = 1, chance = 8 },
        { name = 'lockpick', min = 1, max = 1, chance = 7 },
        { name = 'nothing', min = 0, max = 0, chance = 15 }
    }
}

Config.Notifications = {
    noVehicle = 'Geen voertuig gevonden.',
    noItem = 'Je hebt een lockpick nodig.',
    alreadySearched = 'Dit voertuig is recent al doorzocht.',
    success = 'Je hebt het voertuig doorzocht.',
    failed = 'Je lockpick is afgebroken.',
    cancelled = 'Je bent gestopt.',
    policeAlert = 'Verdachte activiteit bij een voertuig gemeld.'
}
