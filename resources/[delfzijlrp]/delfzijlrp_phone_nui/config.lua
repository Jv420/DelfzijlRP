Config = {}

Config.Debug = false
Config.Command = 'phone'
Config.AltCommand = 'telefoon2'
Config.PhoneItem = 'phone'
Config.RequireItem = false
Config.OpenKey = 'F2'

Config.Brand = {
    name = 'Delfzijl Phone',
    theme = 'yellow',
    city = 'Delfzijl RP'
}

Config.Apps = {
    { id = 'identity', label = 'ID', icon = '🪪', command = nil },
    { id = 'bank', label = 'Bank', icon = '🏦', command = nil },
    { id = 'city', label = 'Gemeente', icon = '🏛️', command = 'gemeente' },
    { id = 'dispatch', label = '112', icon = '🚨', command = '112' },
    { id = 'marketplace', label = 'Markt', icon = '🛒', command = 'mp' },
    { id = 'garage', label = 'Garage', icon = '🚗', command = 'garage' },
    { id = 'business', label = 'Bedrijf', icon = '💼', command = 'bedrijf2' },
    { id = 'housing', label = 'Woning', icon = '🏠', command = 'huis' },
    { id = 'groups', label = 'Groep', icon = '👥', command = 'groep' },
    { id = 'taxi', label = 'Taxi', icon = '🚕', command = 'taxi' },
    { id = 'bus', label = 'Bus', icon = '🚌', command = 'bus' }
}

Config.Text = {
    noPhone = 'Je hebt geen telefoon bij je.',
    noProfile = 'Geen Delfzijl ID gevonden.',
    noBank = 'Geen bankrekening gevonden.',
    loaded = 'Telefoon geladen.'
}
