Config = {}

Config.Command = 'piricars'
Config.BusinessId = 'piricars'
Config.Debug = false

Config.Location = {
    label = 'Piricars Showroom',
    coords = vector3(-33.73, -1102.04, 26.42),
    radius = 3.0,
    blip = { sprite = 225, color = 5, scale = 0.8 }
}

Config.Cars = {
    { model = 'sultan', label = 'Karin Sultan', price = 45000 },
    { model = 'komoda', label = 'Lampadati Komoda', price = 85000 },
    { model = 'schafter3', label = 'Benefactor Schafter V12', price = 95000 },
    { model = 'tailgater2', label = 'Obey Tailgater S', price = 115000 },
    { model = 'paragon', label = 'Enus Paragon R', price = 185000 }
}

Config.Text = {
    open = 'Showroom openen',
    bought = 'Voertuig gekocht en geregistreerd.',
    noMoney = 'Niet genoeg geld.',
    invalid = 'Ongeldige keuze.',
    testdrive = 'Proefrit komt in de volgende versie.'
}
