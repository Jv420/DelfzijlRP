Config = {}

Config.Debug = false
Config.Command = 'kolommer'
Config.JobName = 'mechanic'

Config.Location = {
    label = 'De2Kolommer Delfzijl',
    coords = vector3(941.64, -975.12, 39.50),
    duty = vector3(949.78, -968.21, 39.50),
    storage = vector3(955.25, -972.58, 39.50),
    tow = vector3(930.55, -985.20, 39.50),
    radius = 3.0,
    blip = { sprite = 446, color = 46, scale = 0.8 }
}

Config.Prices = {
    repair = 900,
    clean = 175,
    apk = 1250,
    tow = 1000
}

Config.Items = {
    repairkit = 'repairkit',
    cleaningkit = 'cleaningkit'
}

Config.Text = {
    open = 'De2Kolommer openen',
    duty = 'Dienststatus wijzigen',
    storage = 'Werkplaats opslag',
    noVehicle = 'Geen voertuig gevonden.',
    noAccess = 'Je bent geen medewerker van de garage.',
    noMoney = 'Niet genoeg geld.',
    repaired = 'Voertuig gerepareerd.',
    cleaned = 'Voertuig schoongemaakt.',
    apk = 'APK goedgekeurd en bijgewerkt.',
    towed = 'Voertuig afgesleept.',
    invalid = 'Ongeldige invoer.'
}
