Config = {}

Config.Debug = false
Config.Command = 'telefoon'
Config.PhoneItem = 'phone'
Config.RequireItem = true

Config.Apps = {
    identity = { label = 'Delfzijl ID', icon = 'id-card' },
    bank = { label = 'Bank', icon = 'building-columns' },
    garage = { label = 'Garage/RDW', icon = 'car' },
    dispatch = { label = '112', icon = 'tower-broadcast' },
    business = { label = 'Bedrijven', icon = 'briefcase' },
    ads = { label = 'Advertenties', icon = 'rectangle-ad' },
    contacts = { label = 'Contacten', icon = 'address-book' }
}

Config.Advertisement = {
    price = 250,
    maxLength = 180,
    duration = 15000
}

Config.Text = {
    noPhone = 'Je hebt geen telefoon bij je.',
    invalidInput = 'Ongeldige invoer.',
    adPosted = 'Advertentie geplaatst.',
    noMoney = 'Je hebt niet genoeg geld.',
    noProfile = 'Je hebt nog geen Delfzijl ID.',
    contactSaved = 'Contact opgeslagen.',
    contactDeleted = 'Contact verwijderd.',
    noContacts = 'Geen contacten gevonden.'
}
