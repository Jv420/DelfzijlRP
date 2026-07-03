Config = {}

Config.Debug = false
Config.Command = 'staff'
Config.ReportCommand = 'report'

Config.Groups = {
    admin = true,
    superadmin = true,
    owner = true,
    mod = true
}

Config.Actions = {
    teleportToPlayer = true,
    bringPlayer = true,
    healPlayer = true,
    revivePlayer = true,
    freezePlayer = true,
    vehicleFix = true,
    vehicleClean = true,
    deleteVehicle = true
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot het staffmenu.',
    reportSent = 'Je report is verzonden.',
    reportClosed = 'Report afgesloten.',
    actionDone = 'Actie uitgevoerd.',
    playerNotFound = 'Speler niet gevonden.',
    invalidInput = 'Ongeldige invoer.',
    frozen = 'Speler bevroren of vrijgegeven.'
}
