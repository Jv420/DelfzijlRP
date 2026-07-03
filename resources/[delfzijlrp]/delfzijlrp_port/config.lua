Config = {}

Config.Debug = false
Config.Command = 'haven'
Config.JobCommand = 'havenwerk'

Config.PortOffice = {
    label = 'Havenkantoor Delfzijl',
    coords = vector3(1207.66, -3115.14, 5.54),
    radius = 2.0,
    blip = { sprite = 410, color = 3, scale = 0.8 }
}

Config.CustomsJob = 'customs'
Config.TransportJob = 'trucker'

Config.Terminals = {
    {
        id = 'container_terminal',
        label = 'Containerterminal Delfzijl',
        pickup = vector3(1188.22, -3105.44, 5.54),
        scan = vector3(1216.15, -3097.83, 5.54),
        dropoff = vector3(1245.72, -3122.36, 5.54),
        radius = 3.0
    },
    {
        id = 'fuel_terminal',
        label = 'Tankterminal Delfzijl',
        pickup = vector3(1681.48, -1621.44, 112.48),
        scan = vector3(1701.12, -1611.22, 112.48),
        dropoff = vector3(1720.35, -1600.32, 112.48),
        radius = 3.0
    }
}

Config.CargoTypes = {
    food = { label = 'Voedsel & Supermarktvoorraad', item = 'port_food_crate', payout = { min = 850, max = 1450 } },
    medical = { label = 'Medische voorraad', item = 'port_medical_crate', payout = { min = 950, max = 1600 } },
    electronics = { label = 'Elektronica', item = 'port_electronics_crate', payout = { min = 1200, max = 2100 } },
    fuel = { label = 'Brandstoflevering', item = 'port_fuel_manifest', payout = { min = 1000, max = 1800 } },
    construction = { label = 'Bouwmaterialen', item = 'port_construction_crate', payout = { min = 800, max = 1500 } }
}

Config.Job = {
    cooldown = 180,
    pickupDuration = 7000,
    scanDuration = 6000,
    deliverDuration = 7000,
    customsChance = 20
}

Config.Text = {
    openOffice = 'Havenkantoor openen',
    openWork = 'Havenwerk openen',
    noCargo = 'Je hebt geen actieve lading.',
    jobStarted = 'Havenopdracht gestart.',
    pickedUp = 'Container/lading opgehaald.',
    scanned = 'Lading gescand.',
    delivered = 'Lading afgeleverd.',
    cooldown = 'Je moet even wachten voor een nieuwe opdracht.',
    invalidInput = 'Ongeldige invoer.',
    customsAlert = 'Douanecontrole aangevraagd voor verdachte lading.',
    noAccess = 'Je hebt geen toegang tot deze functie.'
}
