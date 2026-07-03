Config = {}

Config.Debug = false
Config.Command = 'ambulance'
Config.JobName = 'ambulance'

Config.Hospitals = {
    {
        id = 'pillbox',
        label = 'Pillbox Medical Center',
        duty = vector3(310.24, -597.45, 43.29),
        storage = vector3(306.59, -601.64, 43.29),
        checkin = vector3(308.31, -595.24, 43.29),
        blip = { sprite = 61, color = 2, scale = 0.8 }
    }
}

Config.Services = {
    revivePrice = 750,
    healPrice = 250,
    checkinPrice = 500,
    checkinDuration = 10000
}

Config.StorageItems = {
    { name = 'bandage', label = 'Verband', count = 5 },
    { name = 'medikit', label = 'Medikit', count = 2 }
}

Config.Text = {
    noAccess = 'Je bent geen ambulance medewerker.',
    openMenu = 'Ambulance menu openen',
    duty = 'Dienststatus wijzigen',
    storage = 'Medische opslag openen',
    checkin = 'Inchecken bij ziekenhuis',
    revived = 'Patiënt gereanimeerd.',
    healed = 'Patiënt behandeld.',
    noMoney = 'Je hebt niet genoeg geld.',
    invalidInput = 'Ongeldige invoer.',
    playerNotFound = 'Speler niet gevonden.',
    recordCreated = 'Medisch dossier bijgewerkt.'
}
