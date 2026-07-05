Config = {}

Config.Debug = false
Config.Command = 'newgen'

Config.Location = {
    label = 'New Generation',
    coords = vector3(373.58, 326.39, 103.57),
    radius = 2.0,
    blip = { sprite = 140, color = 25, scale = 0.75 }
}

Config.Products = {
    { name = 'coffee', label = 'Koffie', price = 8 },
    { name = 'brownie', label = 'Brownie', price = 25 },
    { name = 'smoothie', label = 'Smoothie', price = 18 },
    { name = 'ng_pack', label = 'NewGen pakket', price = 250 }
}

Config.Text = {
    open = 'New Generation openen',
    bought = 'Aankoop gelukt.',
    noMoney = 'Je hebt niet genoeg geld.',
    invalid = 'Ongeldige keuze.',
    missing = 'Item bestaat niet in ox_inventory.'
}
