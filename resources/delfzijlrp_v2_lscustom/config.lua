Config = {}

Config.Debug = false
Config.Command = 'tune2'

Config.Locations = {
    {
        label = 'LS Customs Delfzijl',
        coords = vector3(-337.1, -136.8, 39.0),
        radius = 4.0,
        blip = { sprite = 72, color = 46, scale = 0.8 }
    }
}

Config.Prices = {
    repair = 1500,
    clean = 250,
    engine1 = 5000,
    engine2 = 12000,
    brakes1 = 3500,
    brakes2 = 8500,
    transmission1 = 4500,
    transmission2 = 10000,
    armor1 = 10000,
    color = 2500,
    save = 0
}

Config.Colors = {
    { label = 'Zwart', primary = 0, secondary = 0 },
    { label = 'Wit', primary = 111, secondary = 111 },
    { label = 'Rood', primary = 27, secondary = 27 },
    { label = 'Blauw', primary = 64, secondary = 64 },
    { label = 'Geel', primary = 88, secondary = 88 },
    { label = 'Groen', primary = 55, secondary = 55 }
}

Config.Text = {
    open = 'Voertuig tunen',
    noVehicle = 'Je zit niet in een voertuig.',
    noMoney = 'Je hebt niet genoeg geld.',
    paid = 'Aanpassing uitgevoerd.',
    saved = 'Voertuig opgeslagen.',
    notOwned = 'Dit voertuig staat niet op jouw naam.'
}
