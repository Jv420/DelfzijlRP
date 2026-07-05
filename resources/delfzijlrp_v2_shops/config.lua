Config = {}

Config.Debug = false
Config.Command = 'shops2'

Config.Shops = {
    {
        id = 'centrum_supermarkt',
        label = 'Supermarkt Centrum',
        coords = vector3(25.75, -1347.32, 29.49),
        radius = 2.0,
        blip = { sprite = 52, color = 2, scale = 0.7 },
        items = {
            { name = 'bread', label = 'Brood', price = 15 },
            { name = 'water', label = 'Water', price = 10 },
            { name = 'phone', label = 'Telefoon', price = 750 },
            { name = 'radio', label = 'Radio', price = 500 },
            { name = 'bandage', label = 'Verband', price = 75 }
        }
    },
    {
        id = 'sandy_supermarkt',
        label = 'Supermarkt Sandy',
        coords = vector3(1961.42, 3740.74, 32.34),
        radius = 2.0,
        blip = { sprite = 52, color = 2, scale = 0.7 },
        items = {
            { name = 'bread', label = 'Brood', price = 15 },
            { name = 'water', label = 'Water', price = 10 },
            { name = 'phone', label = 'Telefoon', price = 750 },
            { name = 'radio', label = 'Radio', price = 500 }
        }
    },
    {
        id = 'paleto_supermarkt',
        label = 'Supermarkt Paleto',
        coords = vector3(1729.21, 6414.13, 35.03),
        radius = 2.0,
        blip = { sprite = 52, color = 2, scale = 0.7 },
        items = {
            { name = 'bread', label = 'Brood', price = 15 },
            { name = 'water', label = 'Water', price = 10 },
            { name = 'phone', label = 'Telefoon', price = 750 },
            { name = 'radio', label = 'Radio', price = 500 }
        }
    },
    {
        id = 'centrum_tankshop',
        label = 'Tankstation Shop',
        coords = vector3(-48.52, -1757.51, 29.42),
        radius = 2.0,
        blip = { sprite = 361, color = 46, scale = 0.7 },
        items = {
            { name = 'water', label = 'Water', price = 10 },
            { name = 'bread', label = 'Broodje', price = 15 },
            { name = 'repairkit', label = 'Reparatiekit', price = 650 },
            { name = 'cleaningkit', label = 'Schoonmaakset', price = 150 },
            { name = 'jerrycan', label = 'Jerrycan', price = 500 }
        }
    },
    {
        id = 'sandy_tankshop',
        label = 'Tankstation Sandy',
        coords = vector3(1698.24, 4924.57, 42.06),
        radius = 2.0,
        blip = { sprite = 361, color = 46, scale = 0.7 },
        items = {
            { name = 'water', label = 'Water', price = 10 },
            { name = 'bread', label = 'Broodje', price = 15 },
            { name = 'repairkit', label = 'Reparatiekit', price = 650 },
            { name = 'jerrycan', label = 'Jerrycan', price = 500 }
        }
    }
}

Config.Text = {
    open = 'Winkel openen',
    noMoney = 'Je hebt niet genoeg geld.',
    bought = 'Aankoop geslaagd.',
    invalid = 'Ongeldig item.',
    itemMissing = 'Dit item bestaat niet in ox_inventory.'
}
