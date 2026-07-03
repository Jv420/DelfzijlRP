Config = {}

Config.Debug = false
Config.UseBlip = true

Config.CityHall = {
    label = 'Gemeentehuis Delfzijl',
    coords = vector3(-544.72, -204.15, 38.22),
    radius = 2.0,
    blip = { sprite = 419, color = 3, scale = 0.8 }
}

Config.Prices = {
    id_card = 150,
    passport = 250,
    driver_license = 500,
    birth_certificate = 100
}

Config.Identity = {
    delfzijlIdPrefix = 'DRP',
    minAge = 16,
    maxAge = 99
}

Config.Items = {
    id_card = 'id_card',
    passport = 'passport',
    driver_license = 'driver_license',
    birth_certificate = 'birth_certificate'
}

Config.Text = {
    openCityHall = 'Gemeentehuis openen',
    noMoney = 'Je hebt niet genoeg geld.',
    profileCreated = 'Je Delfzijl ID is aangemaakt.',
    profileExists = 'Je hebt al een Delfzijl ID.',
    profileMissing = 'Je moet eerst een Delfzijl ID aanvragen.',
    documentIssued = 'Document uitgegeven.',
    invalidInput = 'Ongeldige gegevens ingevuld.',
    playerNotFound = 'Speler niet gevonden.'
}
