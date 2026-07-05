Config = {}

Config.Debug = false
Config.Command = 'horeca'

Config.Places = {
    {
        id = 'centrum',
        label = 'Café Centrum',
        coords = vector3(198.34, -934.89, 30.69),
        radius = 2.0,
        blip = { sprite = 93, color = 46, scale = 0.75 },
        items = {
            { name = 'coffee', label = 'Koffie', price = 8 },
            { name = 'cola', label = 'Cola', price = 10 },
            { name = 'water', label = 'Water', price = 8 },
            { name = 'tosti', label = 'Tosti', price = 25 },
            { name = 'borrelhapjes', label = 'Borrelhapjes', price = 45 }
        }
    },
    {
        id = 'stad_en_lande',
        label = 'Café Stad en Lande',
        coords = vector3(-560.72, -181.65, 38.22),
        radius = 2.0,
        blip = { sprite = 93, color = 5, scale = 0.75 },
        items = {
            { name = 'coffee', label = 'Koffie', price = 8 },
            { name = 'cola', label = 'Cola', price = 10 },
            { name = 'water', label = 'Water', price = 8 },
            { name = 'appelgebak', label = 'Appelgebak', price = 35 },
            { name = 'uitsmijter', label = 'Uitsmijter', price = 55 }
        }
    }
}

Config.Settings = {
    maxAmount = 10,
    maxTip = 500
}

Config.Text = {
    open = 'Café openen',
    bought = 'Bestelling gekocht.',
    noMoney = 'Je hebt niet genoeg geld.',
    invalid = 'Ongeldige keuze.',
    missing = 'Item bestaat niet in ox_inventory.'
}
