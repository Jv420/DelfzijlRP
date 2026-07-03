Config = {}

Config.Debug = false
Config.Command = 'bedrijf'

Config.BusinessOffice = {
    label = 'Kamer van Koophandel Delfzijl',
    coords = vector3(-545.74, -202.79, 38.22),
    radius = 2.0,
    blip = { sprite = 475, color = 3, scale = 0.75 }
}

Config.CreatePrice = 5000
Config.InvoiceFeePercent = 2

Config.BusinessTypes = {
    horeca = 'Horeca',
    transport = 'Transport',
    mechanic = 'Garage/ANWB',
    dealer = 'Voertuigdealer',
    realestate = 'Makelaar',
    security = 'Beveiliging',
    retail = 'Winkel',
    other = 'Overig'
}

Config.Ranks = {
    owner = { label = 'Eigenaar', level = 100 },
    manager = { label = 'Manager', level = 70 },
    employee = { label = 'Medewerker', level = 10 }
}

Config.Text = {
    openOffice = 'Bedrijfsloket openen',
    noAccess = 'Je hebt geen toegang tot dit bedrijf.',
    noMoney = 'Je hebt niet genoeg geld.',
    created = 'Bedrijf geregistreerd.',
    employeeAdded = 'Medewerker toegevoegd.',
    employeeRemoved = 'Medewerker verwijderd.',
    invoiceCreated = 'Factuur aangemaakt.',
    invoicePaid = 'Factuur betaald.',
    invalidInput = 'Ongeldige invoer.',
    notFound = 'Niet gevonden.',
    deposited = 'Geld gestort op bedrijfsrekening.',
    withdrawn = 'Geld opgenomen van bedrijfsrekening.'
}
