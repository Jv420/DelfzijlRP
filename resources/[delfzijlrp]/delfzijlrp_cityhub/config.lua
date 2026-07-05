Config = {}

Config.Debug = false
Config.Command = 'cityhub'
Config.HelpCommand = 'help'

Config.Hub = {
    label = 'Delfzijl RP Infobalie',
    coords = vector3(-540.91, -211.26, 37.65),
    radius = 1.2,
    blip = { sprite = 280, color = 3, scale = 0.8 }
}

Config.Server = {
    name = 'Delfzijl RP',
    discord = 'discord.gg/delfzijlrp',
    website = 'delfzijlrp.nl',
    description = 'Welkom op Delfzijl RP.'
}

Config.Rules = {
    'Blijf in roleplay.',
    'Respecteer andere spelers.',
    'Gebruik /report bij problemen.',
    'Houd het gezellig.'
}

Config.StarterTips = {
    'Gebruik /gemeente voor burgerzaken.',
    'Gebruik /kvk voor bedrijven.',
    'Gebruik /kadaster voor vastgoed.',
    'Gebruik /rdw voor voertuigen.'
}

Config.Locations = {
    { label = 'KVK Delfzijl', command = 'kvk', coords = vector3(-552.91, -211.26, 37.65) },
    { label = 'Kadaster Delfzijl', command = 'kadaster', coords = vector3(-548.91, -211.26, 37.65) },
    { label = 'RDW Delfzijl', command = 'rdw', coords = vector3(-544.91, -211.26, 37.65) },
    { label = 'Delfzijl RP Infobalie', command = 'cityhub', coords = vector3(-540.91, -211.26, 37.65) }
}

Config.Shortcuts = {
    { label = 'Telefoon', command = 'phone', icon = 'mobile-screen' },
    { label = 'Marktplaats', command = 'mp', icon = 'store' },
    { label = 'Woningen', command = 'huis', icon = 'house' },
    { label = 'Bedrijven', command = 'bedrijf2', icon = 'briefcase' },
    { label = 'Groepen', command = 'groep', icon = 'people-group' }
}

Config.Text = {
    openHub = 'Infobalie openen',
    waypointSet = 'Waypoint ingesteld.',
    noData = 'Geen data beschikbaar.'
}
