Config = {}

Config.Debug = false
Config.MinPoliceOnline = 0
Config.PoliceAlertChance = 25

Config.Zones = {
    collect = {
        label = 'Verdacht pakket ophalen',
        icon = 'fa-solid fa-box',
        coords = vector3(1535.25, 1702.15, 109.75),
        radius = 2.0,
        duration = 6000,
        reward = { item = 'suspicious_package', min = 1, max = 2 }
    },

    process = {
        label = 'Pakket sorteren',
        icon = 'fa-solid fa-box-open',
        coords = vector3(1005.18, -3200.42, -38.99),
        radius = 2.0,
        duration = 7500,
        input = { item = 'suspicious_package', amount = 1 },
        reward = { item = 'sealed_contraband', min = 1, max = 1 }
    },

    sell = {
        label = 'Smokkelwaar afleveren',
        icon = 'fa-solid fa-handshake',
        coords = vector3(-217.96, -1673.51, 34.46),
        radius = 2.0,
        duration = 6500,
        input = { item = 'sealed_contraband', amount = 1 },
        payout = { account = 'black_money', min = 450, max = 850 }
    }
}

Config.Notifications = {
    noPolice = 'Er is momenteel te weinig politie in dienst.',
    noItem = 'Je mist de benodigde items.',
    successCollect = 'Je hebt een verdacht pakket gevonden.',
    successProcess = 'Je hebt het pakket gesorteerd.',
    successSell = 'Je hebt de smokkelwaar afgeleverd.',
    cancelled = 'Actie geannuleerd.',
    policeAlert = 'Verdachte overdracht gemeld.'
}
