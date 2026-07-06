Config = {}

Config.Debug = false
Config.Commands = {
    overheid = 'overheid',
    digid = 'digid'
}

Config.Location = {
    label = 'Overheidsloket Delfzijl',
    coords = vector3(-548.10, -203.82, 38.22),
    radius = 2.0,
    blip = { sprite = 419, color = 3, scale = 0.75 }
}

Config.DigidPrice = 100

Config.Apps = {
    { id = 'gemeente', label = 'Gemeente', command = 'gemeente', description = 'Burgerzaken, documenten en vergunningen' },
    { id = 'rdw', label = 'RDW', command = 'rdw', description = 'Voertuigen, kentekens en APK' },
    { id = 'kvk', label = 'KVK', command = 'kvk', description = 'Bedrijven en handelsregister' },
    { id = 'kadaster', label = 'Kadaster', command = 'kadaster', description = 'Woningen en vastgoed' },
    { id = 'belasting', label = 'Belastingdienst', command = '', description = 'Belastingmodule volgt' },
    { id = 'cjib', label = 'CJIB', command = '', description = 'Boetes en betalingen volgen' }
}

Config.Text = {
    open = 'Overheidsloket openen',
    noMoney = 'Je hebt niet genoeg geld.',
    digidCreated = 'DigiD aangemaakt.',
    digidExists = 'Je hebt al een DigiD.',
    noDigid = 'Je hebt nog geen DigiD.',
    done = 'Actie uitgevoerd.'
}
