Config = {}

Config.Debug = false
Config.Command = 'anwb'
Config.JobName = 'mechanic'

Config.Stations = {
    {
        id = 'delfzijl_service',
        label = 'ANWB Delfzijl Servicepunt',
        duty = vector3(949.78, -968.21, 39.50),
        storage = vector3(955.25, -972.58, 39.50),
        service = vector3(941.64, -975.12, 39.50),
        blip = { sprite = 446, color = 46, scale = 0.75 }
    }
}

Config.Prices = {
    repair = 750,
    clean = 150,
    diagnose = 100,
    apk = 1250,
    tow = 1000
}

Config.Repair = {
    duration = 9000,
    useRepairKit = true,
    item = 'repairkit'
}

Config.ArmoryItems = {
    { name = 'repairkit', label = 'Reparatiekit', count = 2 },
    { name = 'cleaningkit', label = 'Schoonmaakset', count = 2 },
    { name = 'towrope', label = 'Sleepkabel', count = 1 }
}

Config.Text = {
    noAccess = 'Je bent geen ANWB medewerker.',
    openMenu = 'ANWB menu openen',
    duty = 'Dienststatus wijzigen',
    storage = 'ANWB opslag openen',
    service = 'Servicepunt openen',
    noVehicle = 'Geen voertuig dichtbij gevonden.',
    repaired = 'Voertuig gerepareerd.',
    cleaned = 'Voertuig schoongemaakt.',
    diagnosed = 'Voertuigdiagnose voltooid.',
    apkRenewed = 'APK vernieuwd.',
    noItem = 'Je mist het benodigde item.',
    noMoney = 'De klant heeft niet genoeg geld.',
    invalidInput = 'Ongeldige invoer.',
    playerNotFound = 'Speler niet gevonden.',
    dutyOn = 'Je bent in dienst.',
    dutyOff = 'Je bent uit dienst.'
}
