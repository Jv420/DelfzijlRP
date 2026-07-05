Config = {}

Config.Command = 'taxirit'
Config.Debug = false
Config.PriceBase = 250
Config.PricePerKm = 35

Config.Stand = {
    label = 'Taxi Delfzijl Ritservice',
    coords = vector3(895.72, -179.25, 74.70),
    radius = 2.0,
    blip = { sprite = 198, color = 5, scale = 0.75 }
}

Config.Destinations = {
    { label = 'Gemeentehuis', coords = vector3(-544.72, -204.15, 38.22) },
    { label = 'RDW / Autodealer', coords = vector3(-42.67, -1098.22, 26.42) },
    { label = 'Kadaster / Vastgoed', coords = vector3(-138.44, -633.91, 168.82) },
    { label = 'KVK', coords = vector3(-1579.65, -565.82, 108.52) },
    { label = 'De2Kolommer', coords = vector3(941.64, -975.12, 39.50) },
    { label = 'Piricars', coords = vector3(-795.62, -220.15, 37.08) },
    { label = 'Ziekenhuis', coords = vector3(298.54, -584.62, 43.26) },
    { label = 'Politie', coords = vector3(441.19, -981.95, 30.69) }
}

Config.Text = {
    open = 'Taxi bestellen',
    noMoney = 'Je hebt niet genoeg geld.',
    paid = 'Taxi betaald. Bestemming ingesteld.',
    arrived = 'Je bent aangekomen.'
}
