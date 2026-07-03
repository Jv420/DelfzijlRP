Config = {}

Config.Debug = false
Config.Command = 'garage'
Config.ImpoundCommand = 'impound'

Config.Impound = {
    price = 2500,
    policeFree = true
}

Config.Garages = {
    {
        id = 'centrum',
        label = 'Garage Centrum',
        coords = vector3(215.13, -809.83, 30.73),
        spawn = vector4(229.72, -800.12, 30.57, 160.0),
        store = vector3(216.67, -786.84, 30.80),
        blip = { sprite = 357, color = 3, scale = 0.7 }
    },
    {
        id = 'haven',
        label = 'Garage Haven',
        coords = vector3(-786.42, -1298.42, 5.0),
        spawn = vector4(-793.92, -1301.72, 5.0, 170.0),
        store = vector3(-781.18, -1306.42, 5.0),
        blip = { sprite = 357, color = 5, scale = 0.7 }
    },
    {
        id = 'sandy',
        label = 'Garage Sandy Shores',
        coords = vector3(1737.62, 3710.21, 34.13),
        spawn = vector4(1728.18, 3710.05, 34.18, 20.0),
        store = vector3(1732.32, 3719.42, 34.18),
        blip = { sprite = 357, color = 17, scale = 0.7 }
    }
}

Config.Impounds = {
    {
        id = 'police_impound',
        label = 'Inbeslagname Depot',
        coords = vector3(409.19, -1623.05, 29.29),
        spawn = vector4(405.12, -1643.62, 29.29, 230.0),
        blip = { sprite = 524, color = 1, scale = 0.7 }
    }
}

Config.Text = {
    openGarage = 'Garage openen',
    storeVehicle = 'Voertuig stallen',
    openImpound = 'Depot openen',
    noVehicle = 'Geen voertuig gevonden.',
    notOwner = 'Dit voertuig staat niet op jouw naam.',
    stored = 'Voertuig gestald.',
    spawned = 'Voertuig opgehaald.',
    alreadyOut = 'Dit voertuig staat al buiten.',
    noMoney = 'Je hebt niet genoeg geld.',
    impounded = 'Voertuig naar depot geplaatst.',
    noVehicles = 'Geen voertuigen gevonden.'
}
