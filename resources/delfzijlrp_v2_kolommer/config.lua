Config = {}

Config.Debug = false
Config.Command = 'kolommer'
Config.JobName = 'mechanic'

Config.Location = {
    label = 'De2Kolommer Delfzijl',
    coords = vector3(724.42, -1088.74, 22.17),
    duty = vector3(731.02, -1088.89, 22.17),
    storage = vector3(736.48, -1078.42, 22.17),
    service = vector3(732.02, -1064.02, 22.17),
    tow = vector3(716.92, -1071.36, 22.17),
    door = vector3(721.76, -1083.31, 22.17),
    towSpawn = vector4(718.10, -1095.42, 22.17, 270.0),
    radius = 3.0,
    blip = { sprite = 446, color = 46, scale = 0.8 }
}

Config.Door = {
    enabled = true,
    prop = 'prop_com_gar_door_01',
    heading = 270.0,
    closedZ = 22.17,
    openZ = 26.30
}

Config.Prices = {
    repair = 900,
    clean = 175,
    apk = 1250,
    tow = 1000,
    engine1 = 5000,
    engine2 = 12000,
    brakes1 = 3500,
    brakes2 = 8500,
    transmission1 = 4500,
    transmission2 = 10000,
    color = 2500
}

Config.Colors = {
    { label = 'Geel De2Kolommer', primary = 88, secondary = 88 },
    { label = 'Zwart', primary = 0, secondary = 0 },
    { label = 'Wit', primary = 111, secondary = 111 },
    { label = 'Rood', primary = 27, secondary = 27 },
    { label = 'Blauw', primary = 64, secondary = 64 }
}

Config.TowVehicles = {
    { model = 'caddy', label = 'Gele sleep caddy' },
    { model = 'towtruck', label = 'Gele sleepwagen' },
    { model = 'towtruck2', label = 'Gele grote sleepwagen' }
}

Config.Items = {
    repairkit = 'repairkit',
    cleaningkit = 'cleaningkit'
}

Config.Text = {
    open = 'De2Kolommer openen',
    duty = 'Dienststatus wijzigen',
    storage = 'Werkplaats opslag',
    door = 'Loodsdeur open/dicht',
    noVehicle = 'Geen voertuig gevonden.',
    noAccess = 'Je bent geen medewerker van de garage.',
    noMoney = 'Niet genoeg geld.',
    repaired = 'Voertuig gerepareerd.',
    cleaned = 'Voertuig schoongemaakt.',
    apk = 'APK goedgekeurd en bijgewerkt.',
    towed = 'Voertuig afgesleept.',
    tuned = 'Tuning uitgevoerd.',
    spawned = 'Voertuig klaargezet.',
    invalid = 'Ongeldige invoer.'
}
