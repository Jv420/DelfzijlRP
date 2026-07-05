Config = {}

Config.Debug = false
Config.Command = 'piricars'

Config.Shop = {
    label = 'Piricars Luxe Auto Dealer',
    coords = vector3(-795.62, -220.15, 37.08),
    preview = vector4(-788.75, -230.66, 37.08, 117.0),
    spawn = vector4(-774.45, -234.84, 37.08, 205.0),
    radius = 2.0,
    blip = { sprite = 326, color = 46, scale = 0.8 }
}

Config.Vehicles = {
    { model = 'adder', label = 'Truffade Adder', price = 850000 },
    { model = 'zentorno', label = 'Pegassi Zentorno', price = 950000 },
    { model = 'turismor', label = 'Turismo R', price = 780000 },
    { model = 't20', label = 'Progen T20', price = 1200000 },
    { model = 'osiris', label = 'Pegassi Osiris', price = 1100000 },
    { model = 'italigtb', label = 'Itali GTB', price = 975000 },
    { model = 'nero', label = 'Truffade Nero', price = 1350000 },
    { model = 'reaper', label = 'Pegassi Reaper', price = 1150000 }
}

Config.Text = {
    open = 'Piricars openen',
    bought = 'Luxe voertuig gekocht en RDW geregistreerd.',
    noMoney = 'Je hebt niet genoeg geld.',
    invalid = 'Ongeldige keuze.'
}
