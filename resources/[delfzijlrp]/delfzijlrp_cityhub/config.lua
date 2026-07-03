Config = {}

Config.Debug = false
Config.Command = 'cityhub'
Config.HelpCommand = 'help'

Config.Hub = {
    label = 'Delfzijl RP Infobalie',
    coords = vector3(-540.91, -211.26, 37.65),
    radius = 2.0,
    blip = { sprite = 280, color = 3, scale = 0.8 }
}

Config.Server = {
    name = 'Delfzijl RP',
    discord = 'discord.gg/delfzijlrp',
    website = 'delfzijlrp.nl',
    description = 'Nederlandse ESX Legacy roleplay server met eigen Delfzijl systemen.'
}

Config.Rules = {
    'Blijf altijd in roleplay tenzij staff anders aangeeft.',
    'Gebruik gezond verstand en respecteer andere spelers.',
    'Geen VDM/RDM, combat logging of failRP.',
    'Gebruik /report bij problemen of bugs.',
    'Houd Nederlandse RP realistisch en gezellig.'
}

Config.StarterTips = {
    'Ga eerst naar het Gemeentehuis om je Delfzijl ID aan te maken.',
    'Open je telefoon met /phone of F2 als je een telefoonitem hebt.',
    'Gebruik /bank voor je IBAN en transacties.',
    'Gebruik /werk voor legale burgerbanen.',
    'Gebruik /112 voor hulpdiensten en /report voor staff.'
}

Config.Locations = {
    { label = 'Gemeentehuis', command = 'gemeente', coords = vector3(-544.72, -204.15, 38.22) },
    { label = 'Bank', command = 'bank', coords = vector3(149.91, -1040.74, 29.37) },
    { label = 'UWV Werkcentrum', command = 'werk', coords = vector3(-268.86, -955.32, 31.22) },
    { label = 'Taxi Centrale', command = 'taxi', coords = vector3(895.33, -179.21, 74.70) },
    { label = 'Ziekenhuis', command = 'ambulance', coords = vector3(310.24, -597.45, 43.29) },
    { label = 'ANWB', command = 'anwb', coords = vector3(-347.65, -133.42, 39.01) },
    { label = 'Politiebureau', command = 'politie', coords = vector3(441.21, -981.92, 30.69) }
}

Config.Shortcuts = {
    { label = 'Telefoon', command = 'phone', icon = 'mobile-screen' },
    { label = 'Marktplaats', command = 'mp', icon = 'store' },
    { label = 'Woningen', command = 'woning', icon = 'house' },
    { label = 'Bedrijven', command = 'bedrijf', icon = 'briefcase' },
    { label = 'Groepen', command = 'groep', icon = 'people-group' },
    { label = 'Meldkamer', command = 'meldkamer', icon = 'tower-broadcast' }
}

Config.Text = {
    openHub = 'CityHub openen',
    waypointSet = 'Waypoint ingesteld.',
    noData = 'Geen data beschikbaar.'
}
