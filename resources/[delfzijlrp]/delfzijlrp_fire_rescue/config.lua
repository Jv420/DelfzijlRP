Config = {}

Config.Debug = false
Config.Command = 'brandweer'
Config.JobName = 'fire'

Config.Stations = {
    {
        id = 'delfzijl_fire',
        label = 'Brandweer Delfzijl',
        duty = vector3(1200.41, -1465.63, 34.86),
        garage = vector3(1190.55, -1461.24, 34.86),
        storage = vector3(1207.35, -1471.88, 34.86),
        spawn = vector4(1182.61, -1458.82, 34.86, 0.0),
        blip = { sprite = 436, color = 1, scale = 0.8 }
    }
}

Config.Vehicles = {
    { label = 'Brandweerwagen', model = 'firetruk' },
    { label = 'Commandovoertuig', model = 'lguard' }
}

Config.Incidents = {
    vehicle_fire = {
        label = 'Voertuigbrand',
        duration = 10000,
        payout = { min = 700, max = 1300 },
        locations = {
            { id = 'vf_haven', coords = vector3(-770.41, -1320.22, 5.0), radius = 3.0 },
            { id = 'vf_centrum', coords = vector3(228.73, -801.52, 30.56), radius = 3.0 }
        }
    },
    industrial_alarm = {
        label = 'Industrieel alarm',
        duration = 14000,
        payout = { min = 1200, max = 2200 },
        locations = {
            { id = 'ind_haven_1', coords = vector3(1208.22, -3115.64, 5.54), radius = 3.0 },
            { id = 'ind_terminal_1', coords = vector3(1687.15, -1624.42, 112.48), radius = 3.0 }
        }
    },
    road_assist = {
        label = 'Technische hulpverlening',
        duration = 9000,
        payout = { min = 500, max = 1000 },
        locations = {
            { id = 'road_1', coords = vector3(402.31, -1631.11, 29.29), radius = 3.0 },
            { id = 'road_2', coords = vector3(-317.22, -1533.38, 27.54), radius = 3.0 }
        }
    }
}

Config.Equipment = {
    { name = 'fire_extinguisher', label = 'Brandblusser', count = 1 },
    { name = 'fire_hose', label = 'Brandslang', count = 1 },
    { name = 'firstaid', label = 'EHBO set', count = 2 }
}

Config.Text = {
    noAccess = 'Je bent geen brandweer medewerker.',
    duty = 'Dienststatus wijzigen',
    garage = 'Brandweer garage openen',
    storage = 'Brandweer opslag openen',
    incidentStarted = 'Incident gestart.',
    incidentDone = 'Incident afgehandeld.',
    noIncident = 'Geen actief incident gevonden.',
    alreadyActive = 'Je hebt al een actief incident.',
    openMenu = 'Brandweer menu openen',
    dispatchSent = 'Brandweermelding verzonden.',
    dutyOn = 'Je bent in dienst.',
    dutyOff = 'Je bent uit dienst.'
}
