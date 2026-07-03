Config = {}

Config.Debug = false
Config.Command = 'phone'
Config.AltCommand = 'telefoon2'
Config.PhoneItem = 'phone'
Config.RequireItem = true
Config.OpenKey = 'F2'

Config.Brand = {
    name = 'Delfzijl Phone',
    theme = 'yellow',
    city = 'Delfzijl RP'
}

Config.Apps = {
    { id = 'identity', label = 'ID', icon = '🪪', command = nil },
    { id = 'bank', label = 'Bank', icon = '🏦', command = nil },
    { id = 'dispatch', label = '112', icon = '🚨', command = '112' },
    { id = 'marketplace', label = 'Markt', icon = '🛒', command = 'mp' },
    { id = 'garage', label = 'RDW', icon = '🚗', command = 'rdw' },
    { id = 'business', label = 'Bedrijf', icon = '💼', command = 'bedrijf' },
    { id = 'housing', label = 'Woning', icon = '🏠', command = 'woning' },
    { id = 'groups', label = 'Groep', icon = '👥', command = 'groep' },
    { id = 'taxi', label = 'Taxi', icon = '🚕', command = 'taxi' }
}

Config.Text = {
    noPhone = 'Je hebt geen telefoon bij je.',
    noProfile = 'Geen Delfzijl ID gevonden.',
    noBank = 'Geen bankrekening gevonden.',
    loaded = 'Telefoon geladen.'
}
