Config = {}

Config.Debug = false
Config.Command = 'politie'
Config.JobName = 'police'

Config.Stations = {
    {
        id = 'missionrow',
        label = 'Politiebureau Mission Row',
        duty = vector3(441.21, -981.92, 30.69),
        evidence = vector3(475.42, -991.18, 26.27),
        armory = vector3(482.62, -995.41, 30.69),
        blip = { sprite = 60, color = 29, scale = 0.75 }
    }
}

Config.Fines = {
    traffic = {
        { label = 'Te hard rijden', amount = 250 },
        { label = 'Fout parkeren', amount = 150 },
        { label = 'Roekeloos rijgedrag', amount = 750 }
    },
    public_order = {
        { label = 'Openbare orde verstoren', amount = 400 },
        { label = 'Niet opvolgen aanwijzing', amount = 300 }
    }
}

Config.ArmoryItems = {
    { name = 'radio', label = 'Portofoon', count = 1 },
    { name = 'bandage', label = 'Verband', count = 3 }
}

Config.Text = {
    noAccess = 'Je bent geen politieagent.',
    openMenu = 'Politiemenu openen',
    duty = 'Dienststatus wijzigen',
    evidence = 'Bewijskluis openen',
    armory = 'Politie-uitrusting openen',
    fineSent = 'Boete geregistreerd.',
    vehicleChecked = 'Voertuig gecontroleerd.',
    statusUpdated = 'Voertuigstatus bijgewerkt.',
    invalidInput = 'Ongeldige invoer.',
    playerNotFound = 'Speler niet gevonden.'
}
