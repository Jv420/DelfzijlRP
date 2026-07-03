Config = {}

Config.Debug = false
Config.Command = 'taxi'
Config.JobName = 'taxi'

Config.Company = {
    label = 'Delfzijl Taxi Centrale',
    duty = vector3(895.33, -179.21, 74.70),
    garage = vector3(908.21, -177.31, 74.22),
    spawn = vector4(913.62, -163.18, 74.54, 198.0),
    blip = { sprite = 198, color = 5, scale = 0.8 }
}

Config.Vehicles = {
    { label = 'Taxi', model = 'taxi' },
    { label = 'Shuttlebus', model = 'rentalbus' }
}

Config.Meter = {
    startPrice = 50,
    pricePerKm = 120,
    minimumFare = 150,
    companyFeePercent = 5
}

Config.NPCRoutes = {
    {
        label = 'Centrum naar Ziekenhuis',
        pickup = vector3(215.76, -810.12, 30.73),
        dropoff = vector3(305.15, -595.21, 43.29),
        payout = { min = 350, max = 650 }
    },
    {
        label = 'Airport naar Centrum',
        pickup = vector3(-1037.35, -2737.65, 20.17),
        dropoff = vector3(215.76, -810.12, 30.73),
        payout = { min = 700, max = 1200 }
    },
    {
        label = 'Haven naar Taxi Centrale',
        pickup = vector3(-806.91, -1310.22, 5.0),
        dropoff = vector3(895.33, -179.21, 74.70),
        payout = { min = 500, max = 900 }
    }
}

Config.Text = {
    noAccess = 'Je bent geen taxichauffeur.',
    duty = 'Dienststatus wijzigen',
    garage = 'Taxi garage openen',
    openMenu = 'Taxi menu openen',
    meterStarted = 'Taximeter gestart.',
    meterStopped = 'Taximeter gestopt.',
    fareCharged = 'Rit afgerekend.',
    noVehicle = 'Je zit niet in een taxi voertuig.',
    playerNotFound = 'Speler niet gevonden.',
    invalidInput = 'Ongeldige invoer.',
    routeStarted = 'NPC-rit gestart.',
    routeCompleted = 'NPC-rit voltooid.',
    dutyOn = 'Je bent in dienst.',
    dutyOff = 'Je bent uit dienst.'
}
