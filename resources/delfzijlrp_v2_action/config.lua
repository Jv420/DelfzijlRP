Config = {}

Config.Debug = false
Config.Command = 'action'

Config.Shop = {
    label = 'Action Delfzijl',
    coords = vector3(46.05, -1749.61, 29.63),
    radius = 2.0,
    blip = { sprite = 52, color = 5, scale = 0.7 }
}

Config.Items = {
    { name = 'water', label = 'Goedkope waterfles', price = 5 },
    { name = 'bread', label = 'Budget broodje', price = 7 },
    { name = 'bandage', label = 'Goedkoop verband', price = 35 },
    { name = 'cleaningkit', label = 'Schoonmaakset', price = 95 },
    { name = 'repairkit', label = 'Budget reparatiekit', price = 450 },
    { name = 'radio', label = 'Budget radio', price = 350 },
    { name = 'phone', label = 'Budget telefoon', price = 550 }
}

Config.Text = {
    open = 'Action openen',
    bought = 'Aankoop geslaagd.',
    noMoney = 'Je hebt niet genoeg geld.',
    invalid = 'Ongeldige keuze.',
    missing = 'Item bestaat niet in ox_inventory.'
}
