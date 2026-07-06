Config = {}

Config.Command = 'action'
Config.BusinessId = 'action'
Config.Debug = false

Config.Location = {
    label = 'Action Delfzijl',
    coords = vector3(25.76, -1345.45, 29.50),
    radius = 2.0,
    blip = { sprite = 52, color = 5, scale = 0.75 }
}

Config.Products = {
    { item = 'water', label = 'Flesje water', price = 3, amount = 1 },
    { item = 'bread', label = 'Broodje', price = 4, amount = 1 },
    { item = 'phone_charger', label = 'Telefoon oplader', price = 25, amount = 1 },
    { item = 'battery', label = 'Batterijen', price = 8, amount = 1 },
    { item = 'ducttape', label = 'Ducttape', price = 12, amount = 1 },
    { item = 'flashlight', label = 'Zaklamp', price = 18, amount = 1 },
    { item = 'firstaid', label = 'EHBO doos', price = 35, amount = 1 },
    { item = 'cleaningkit', label = 'Schoonmaakset', price = 20, amount = 1 },
    { item = 'umbrella', label = 'Paraplu', price = 15, amount = 1 },
    { item = 'notepad', label = 'Notitieblok', price = 5, amount = 1 }
}

Config.Text = {
    open = 'Action openen',
    bought = 'Aankoop gelukt.',
    noMoney = 'Je hebt niet genoeg geld.',
    missingItem = 'Item bestaat niet in ox_inventory.',
    invalid = 'Ongeldige aankoop.'
}
