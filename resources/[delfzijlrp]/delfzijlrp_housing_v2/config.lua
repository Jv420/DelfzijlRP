Config = {}

Config.Debug = false
Config.Command = 'kadaster'
Config.HouseCommand = 'huis'

Config.Office = {
    label = 'Kadaster Delfzijl',
    coords = vector3(-548.91, -211.26, 37.65),
    radius = 1.2,
    blip = { sprite = 475, color = 46, scale = 0.75 }
}

Config.Defaults = {
    rentDays = 7,
    transferTaxPercent = 2,
    stashSlots = 80,
    stashWeight = 180000
}

Config.PropertyTypes = {
    apartment = 'Appartement',
    house = 'Woning',
    farm = 'Boerderij',
    harbor = 'Havenwoning',
    office = 'Bedrijfspand',
    boat = 'Woonboot'
}

Config.StashTypes = {
    general = { label = 'Algemene opslag', slots = 80, weight = 180000 },
    wardrobe = { label = 'Kledingkast', slots = 50, weight = 50000 },
    fridge = { label = 'Koelkast', slots = 40, weight = 80000 }
}

Config.Properties = {
    {
        id = 'kad_apt_001',
        cadastral = 'DZL-A-1001',
        address = 'Havenstraat 12A',
        postal = '9934 AB',
        type = 'apartment',
        buildYear = 1998,
        woz = 165000,
        price = 185000,
        rent = 5500,
        door = vector3(-803.06, -1311.05, 5.0),
        inside = vector4(151.46, -1007.74, -99.0, 0.0),
        exit = vector3(151.46, -1007.74, -99.0),
        stashes = {
            general = vector3(151.31, -1003.04, -99.0),
            wardrobe = vector3(152.21, -1001.28, -99.0),
            fridge = vector3(154.14, -1004.55, -99.0)
        },
        blip = { sprite = 40, color = 3, scale = 0.6 }
    },
    {
        id = 'kad_house_001',
        cadastral = 'DZL-B-2044',
        address = 'Noorderlaan 8',
        postal = '9934 CD',
        type = 'house',
        buildYear = 1984,
        woz = 245000,
        price = 275000,
        rent = 8500,
        door = vector3(1265.64, -703.57, 64.56),
        inside = vector4(346.52, -1012.82, -99.2, 357.0),
        exit = vector3(346.52, -1012.82, -99.2),
        stashes = {
            general = vector3(351.86, -998.73, -99.2),
            wardrobe = vector3(350.62, -993.58, -99.2),
            fridge = vector3(344.18, -1001.08, -99.2)
        },
        blip = { sprite = 40, color = 2, scale = 0.6 }
    },
    {
        id = 'kad_boat_001',
        cadastral = 'DZL-WB-3001',
        address = 'Jachthaven Steiger 3',
        postal = '9934 HV',
        type = 'boat',
        buildYear = 2007,
        woz = 98000,
        price = 120000,
        rent = 4500,
        door = vector3(-1605.44, 5258.38, 3.97),
        inside = vector4(266.01, -1007.36, -101.01, 357.0),
        exit = vector3(266.01, -1007.36, -101.01),
        stashes = {
            general = vector3(265.89, -999.35, -99.01),
            wardrobe = vector3(259.72, -1004.04, -99.01),
            fridge = vector3(262.02, -1002.14, -99.01)
        },
        blip = { sprite = 410, color = 5, scale = 0.6 }
    }
}

Config.Text = {
    openOffice = 'Kadaster openen',
    openProperty = 'Woning openen',
    exitProperty = 'Woning verlaten',
    noAccess = 'Je hebt geen toegang tot dit pand.',
    noMoney = 'Je hebt niet genoeg geld.',
    bought = 'Pand gekocht en ingeschreven bij het Kadaster.',
    rented = 'Huurcontract aangemaakt.',
    keyGiven = 'Sleutel uitgegeven.',
    keyRevoked = 'Sleutel ingetrokken.',
    invalidInput = 'Ongeldige invoer.',
    notOwner = 'Je bent niet de eigenaar.',
    alreadyOwned = 'Dit pand is al verkocht.',
    noProperties = 'Geen panden gevonden.'
}
