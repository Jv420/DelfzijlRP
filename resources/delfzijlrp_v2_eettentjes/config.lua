Config = {}

Config.Debug = false
Config.Command = 'eten'

Config.Stands = {
    {
        id = 'alanya',
        label = 'Alanya',
        coords = vector3(113.22, -1038.61, 29.29),
        radius = 2.0,
        blip = { sprite = 52, color = 47, scale = 0.7 },
        items = {
            { name = 'alanya_broodje', label = 'Turks broodje', price = 45 },
            { name = 'alanya_kapsalon', label = 'Kapsalon', price = 75 },
            { name = 'alanya_pizza', label = 'Pizza', price = 85 },
            { name = 'water', label = 'Water', price = 10 }
        }
    },
    {
        id = 'sharazan',
        label = 'Sharazan',
        coords = vector3(125.84, -1038.25, 29.29),
        radius = 2.0,
        blip = { sprite = 52, color = 5, scale = 0.7 },
        items = {
            { name = 'sharazan_burger', label = 'Burger', price = 55 },
            { name = 'sharazan_patat', label = 'Patat', price = 35 },
            { name = 'sharazan_tosti_leroy', label = 'Tosti Leroy', price = 50 },
            { name = 'water', label = 'Water', price = 10 }
        }
    },
    {
        id = 'milas',
        label = "Mila's Foodtruck",
        coords = vector3(137.26, -1038.04, 29.29),
        radius = 2.0,
        blip = { sprite = 52, color = 2, scale = 0.7 },
        items = {
            { name = 'milas_roti', label = 'Roti rol', price = 70 },
            { name = 'milas_bara', label = 'Bara', price = 40 },
            { name = 'milas_saoto', label = 'Saoto soep', price = 65 },
            { name = 'water', label = 'Water', price = 10 }
        }
    }
}

Config.Extras = {
    tipEnabled = true,
    maxAmount = 10
}

Config.Text = {
    open = 'Menu openen',
    bought = 'Eten gekocht.',
    noMoney = 'Je hebt niet genoeg geld.',
    invalid = 'Ongeldige keuze.',
    missing = 'Item bestaat niet in ox_inventory.'
}
