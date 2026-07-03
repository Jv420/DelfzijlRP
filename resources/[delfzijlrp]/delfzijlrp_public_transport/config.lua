Config = {}

Config.Debug = false
Config.Command = 'bus'
Config.DriverCommand = 'busdienst'
Config.JobName = 'busdriver'

Config.Depot = {
    label = 'Qbuzz Delfzijl Depot',
    coords = vector3(454.79, -607.74, 28.57),
    garage = vector3(462.66, -606.91, 28.50),
    spawn = vector4(471.23, -583.61, 28.50, 175.0),
    radius = 2.0,
    blip = { sprite = 513, color = 5, scale = 0.8 }
}

Config.Vehicle = {
    model = 'bus',
    platePrefix = 'QBZ'
}

Config.Ticket = {
    item = 'bus_ticket',
    price = 45,
    dayPassPrice = 250,
    fineNoTicket = 150
}

Config.Routes = {
    {
        id = 'line_1',
        label = 'Lijn 1 Centrum - Haven - Ziekenhuis',
        payout = 950,
        stops = {
            { id = 'centrum', label = 'Delfzijl Centrum', coords = vector3(215.76, -810.12, 30.73) },
            { id = 'haven', label = 'Delfzijl Haven', coords = vector3(-786.42, -1298.42, 5.0) },
            { id = 'ziekenhuis', label = 'Ziekenhuis', coords = vector3(305.15, -595.21, 43.29) }
        }
    },
    {
        id = 'line_2',
        label = 'Lijn 2 Centrum - KVK - Gemeentehuis',
        payout = 700,
        stops = {
            { id = 'centrum', label = 'Delfzijl Centrum', coords = vector3(215.76, -810.12, 30.73) },
            { id = 'kvk', label = 'KVK Delfzijl', coords = vector3(-552.91, -190.35, 38.22) },
            { id = 'gemeente', label = 'Gemeentehuis', coords = vector3(-544.72, -204.15, 38.22) }
        }
    }
}

Config.StopDuration = 6000
Config.RouteCooldown = 120

Config.Text = {
    openStop = 'Bushalte openen',
    openDepot = 'Busdepot openen',
    noAccess = 'Je bent geen buschauffeur.',
    noMoney = 'Je hebt niet genoeg geld.',
    ticketBought = 'Busticket gekocht.',
    routeStarted = 'Busroute gestart.',
    routeComplete = 'Busroute afgerond.',
    noRoute = 'Je hebt geen actieve busroute.',
    nextStop = 'Rijd naar de volgende halte.',
    stopDone = 'Halte afgerond.',
    cooldown = 'Je moet even wachten voor een nieuwe route.'
}
