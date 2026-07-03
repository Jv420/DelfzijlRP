Config = {}

Config.Debug = false
Config.Command = 'gevangenis'
Config.AdminCommand = 'straf'

Config.AccessJobs = {
    police = true,
    judge = true
}

Config.Prison = {
    label = 'Penitentiaire Inrichting Delfzijl',
    intake = vector3(1845.91, 2585.87, 45.67),
    release = vector4(1848.05, 2586.29, 45.67, 270.0),
    cell = vector4(1765.32, 2565.95, 45.56, 180.0),
    yard = vector3(1775.52, 2551.16, 45.56),
    radius = 2.0,
    blip = { sprite = 188, color = 1, scale = 0.75 }
}

Config.Sentences = {
    minMinutes = 1,
    maxMinutes = 180,
    taskReductionMinutes = 2
}

Config.Tasks = {
    {
        id = 'clean_yard',
        label = 'Binnenplaats schoonmaken',
        coords = vector3(1775.52, 2551.16, 45.56),
        duration = 8000
    },
    {
        id = 'laundry',
        label = 'Wasruimte helpen',
        coords = vector3(1786.62, 2560.38, 45.67),
        duration = 8000
    },
    {
        id = 'kitchen',
        label = 'Keuken ondersteunen',
        coords = vector3(1780.51, 2591.23, 45.79),
        duration = 8000
    }
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot dit gevangenissysteem.',
    openMenu = 'Gevangenismenu openen',
    intake = 'Intake openen',
    sentenced = 'Straf geregistreerd.',
    released = 'Speler vrijgelaten.',
    noSentence = 'Geen actieve straf gevonden.',
    taskDone = 'Taak afgerond. Strafduur verminderd.',
    invalidInput = 'Ongeldige invoer.',
    playerNotFound = 'Speler niet gevonden.'
}
