Config = {}

Config.Command = 'jobmenu'
Config.ClockInCommand = 'indienst'
Config.ClockOutCommand = 'uitdienst'
Config.Debug = false

Config.DefaultPayPerMinute = 35
Config.MaxShiftMinutes = 240

Config.Roles = {
    owner = 'Eigenaar',
    manager = 'Manager',
    chef = 'Chef-kok',
    cook = 'Kok',
    cashier = 'Kassamedewerker',
    courier = 'Bezorger',
    mechanic = 'Monteur',
    dealer = 'Verkoper',
    employee = 'Medewerker',
    trainee = 'Stagiair'
}

Config.Businesses = {
    'alanya',
    'sharazan',
    'milas',
    'cafe_centrum',
    'stad_lande',
    'action',
    'piricars',
    'de2kolommer',
    'taxi'
}

Config.Text = {
    noBusiness = 'Bedrijf niet gevonden.',
    noAccess = 'Je werkt niet bij dit bedrijf.',
    alreadyOnDuty = 'Je bent al in dienst.',
    notOnDuty = 'Je bent niet in dienst.',
    clockedIn = 'Je bent in dienst gegaan.',
    clockedOut = 'Je bent uit dienst gegaan.',
    paid = 'Salaris uitbetaald.',
    hired = 'Medewerker toegevoegd.',
    fired = 'Medewerker uitgeschreven.',
    invalid = 'Ongeldige invoer.'
}
