Config = {}

Config.Command = 'gemeente'
Config.Debug = false

Config.Location = {
    label = 'Gemeente Delfzijl',
    coords = vector3(-544.91, -211.26, 37.65),
    radius = 2.0,
    blip = { sprite = 280, color = 3, scale = 0.75 }
}

Config.Prices = {
    idkaart = 150,
    rijbewijs = 350,
    buskaartje = 25,
    visvergunning = 250,
    werkvergunning = 500,
    uittreksel = 200
}

Config.Items = {
    idkaart = 'idkaart',
    rijbewijs = 'rijbewijs',
    buskaartje = 'buskaartje',
    visvergunning = 'visvergunning',
    werkvergunning = 'werkvergunning',
    uittreksel = 'uittreksel_brp'
}

Config.Text = {
    open = 'Gemeente openen',
    noMoney = 'Je hebt niet genoeg geld.',
    done = 'Aanvraag verwerkt.',
    missingItem = 'Item bestaat nog niet in ox_inventory.',
    invalid = 'Ongeldige aanvraag.'
}
