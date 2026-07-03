Config = {}

Config.Debug = false
Config.UseBlips = true
Config.Currency = '€'

Config.PersonalGarages = {
    {
        id = 'centrum',
        label = 'Garage Centrum',
        coords = vector3(215.12, -809.88, 30.73),
        spawn = vector4(229.56, -800.12, 30.57, 157.0),
        store = vector3(216.44, -786.34, 30.82),
        blip = { sprite = 357, color = 3, scale = 0.75 }
    },
    {
        id = 'haven',
        label = 'Garage Haven',
        coords = vector3(-797.45, -1316.92, 5.0),
        spawn = vector4(-790.2, -1301.5, 5.0, 170.0),
        store = vector3(-807.34, -1309.31, 5.0),
        blip = { sprite = 357, color = 3, scale = 0.75 }
    }
}

Config.JobGarages = {
    police = {
        label = 'Politie Garage',
        coords = vector3(441.22, -1013.25, 28.6),
        spawn = vector4(446.32, -1025.77, 28.65, 5.0),
        vehicles = {
            { label = 'Politie Cruiser', model = 'police' },
            { label = 'Politie Buffalo', model = 'police2' },
            { label = 'Politie Bike', model = 'policeb' }
        }
    },
    ambulance = {
        label = 'Ambulance Garage',
        coords = vector3(295.91, -603.18, 43.3),
        spawn = vector4(294.12, -610.24, 43.33, 70.0),
        vehicles = {
            { label = 'Ambulance', model = 'ambulance' }
        }
    },
    mechanic = {
        label = 'ANWB Garage',
        coords = vector3(-356.41, -128.12, 39.43),
        spawn = vector4(-370.44, -107.87, 38.68, 70.0),
        vehicles = {
            { label = 'Sleepwagen', model = 'towtruck' },
            { label = 'Servicebus', model = 'burrito3' }
        }
    }
}

Config.Tracker = {
    enabled = true,
    installItem = 'vehicle_tracker',
    removeItem = 'tracker_remover',
    installDuration = 7000,
    removeDuration = 9000,
    requireOwnerForInstall = true,
    showOnlyOwnedVehicles = true
}

Config.Text = {
    openGarage = 'Garage openen',
    storeVehicle = 'Voertuig opslaan',
    jobGarage = 'Werkgarage openen',
    noVehicle = 'Je zit niet in een voertuig.',
    notOwner = 'Dit voertuig staat niet op jouw naam.',
    stored = 'Voertuig opgeslagen.',
    spawned = 'Voertuig uitgehaald.',
    noVehicles = 'Je hebt geen voertuigen in deze garage.',
    spawnBlocked = 'Spawnplek is geblokkeerd.',
    noTracker = 'Dit voertuig heeft geen tracker.',
    trackerInstalled = 'Tracker geïnstalleerd.',
    trackerRemoved = 'Tracker verwijderd.',
    missingTrackerItem = 'Je mist een tracker-item.',
    missingRemoverItem = 'Je mist een tracker-verwijderaar.'
}
