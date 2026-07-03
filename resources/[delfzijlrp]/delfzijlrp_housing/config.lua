Config = {}

Config.Debug = false
Config.Command = 'woning'
Config.UseBlips = true

Config.DefaultStashSlots = 60
Config.DefaultStashWeight = 120000
Config.RentDays = 7

Config.Houses = {
    {
        id = 'legion_app_1',
        label = 'Appartement Legion 1',
        type = 'apartment',
        price = 75000,
        rent = 3500,
        door = vector3(312.89, -218.81, 54.22),
        inside = vector4(266.01, -1007.36, -101.01, 357.0),
        exit = vector3(266.01, -1007.36, -101.01),
        stash = vector3(265.89, -999.35, -99.01),
        blip = { sprite = 40, color = 3, scale = 0.6 }
    },
    {
        id = 'mirror_house_1',
        label = 'Woning Mirror Park 1',
        type = 'house',
        price = 185000,
        rent = 8000,
        door = vector3(1265.64, -703.57, 64.56),
        inside = vector4(346.52, -1012.82, -99.2, 357.0),
        exit = vector3(346.52, -1012.82, -99.2),
        stash = vector3(351.86, -998.73, -99.2),
        blip = { sprite = 40, color = 2, scale = 0.6 }
    },
    {
        id = 'haven_loft_1',
        label = 'Haven Loft 1',
        type = 'loft',
        price = 120000,
        rent = 5500,
        door = vector3(-803.06, -1311.05, 5.0),
        inside = vector4(151.46, -1007.74, -99.0, 0.0),
        exit = vector3(151.46, -1007.74, -99.0),
        stash = vector3(151.31, -1003.04, -99.0),
        blip = { sprite = 40, color = 5, scale = 0.6 }
    }
}

Config.Text = {
    openHouse = 'Woning bekijken',
    exitHouse = 'Woning verlaten',
    openStash = 'Opslag openen',
    bought = 'Woning gekocht.',
    rented = 'Woning gehuurd.',
    sold = 'Woning verkocht.',
    noMoney = 'Je hebt niet genoeg geld.',
    noAccess = 'Je hebt geen toegang tot deze woning.',
    notOwner = 'Je bent niet de eigenaar.',
    keyGiven = 'Woning sleutel gegeven.',
    keyReceived = 'Je hebt een woningsleutel ontvangen.',
    invalidInput = 'Ongeldige invoer.',
    alreadyOwned = 'Deze woning is al in bezit.',
    available = 'Beschikbaar'
}
