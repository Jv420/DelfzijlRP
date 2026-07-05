Config = {}

Config.Debug = false
Config.Command = 'dealer2'

Config.Shop = {
    label = 'Delfzijl Auto Dealer',
    coords = vector3(-56.9, -1096.9, 26.4),
    spawn = vector4(-44.6, -1097.7, 26.4, 69.0),
    preview = vector4(-47.4, -1094.1, 26.4, 120.0),
    radius = 2.0,
    blip = { sprite = 326, color = 46, scale = 0.8 }
}

Config.Categories = {
    compact = 'Compact',
    sedan = 'Sedan',
    suv = 'SUV',
    sport = 'Sport',
    service = 'Dienstvoertuigen'
}

Config.Vehicles = {
    { model = 'blista', label = 'Blista', category = 'compact', price = 7500 },
    { model = 'asea', label = 'Asea', category = 'sedan', price = 9500 },
    { model = 'tailgater', label = 'Tailgater', category = 'sedan', price = 18500 },
    { model = 'baller', label = 'Baller', category = 'suv', price = 35000 },
    { model = 'comet2', label = 'Comet', category = 'sport', price = 65000 },
    { model = 'sultan', label = 'Sultan', category = 'sport', price = 42000 }
}

Config.Text = {
    open = 'Auto dealer openen',
    bought = 'Voertuig gekocht en geregistreerd bij RDW.',
    noMoney = 'Je hebt niet genoeg geld.',
    spawnBlocked = 'Spawnplek is bezet.',
    invalid = 'Ongeldige keuze.'
}
