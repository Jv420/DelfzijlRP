Config = {}

Config.Debug = false
Config.Command = 'bedrijf2'
Config.OfficeCommand = 'kvk'
Config.CreatePrice = 25000

Config.KvkOffice = {
    label = 'KVK Delfzijl',
    coords = vector3(-552.91, -211.26, 37.65),
    radius = 1.2,
    blip = { sprite = 475, color = 5, scale = 0.75 }
}

Config.BusinessTypes = {
    shop = 'Winkel',
    transport = 'Transportbedrijf',
    horeca = 'Horeca',
    service = 'Dienstverlening',
    port = 'Havenbedrijf',
    realestate = 'Vastgoed',
    media = 'Media',
    other = 'Overig'
}

Config.Ranks = {
    owner = { label = 'Eigenaar', level = 100 },
    director = { label = 'Directeur', level = 80 },
    manager = { label = 'Manager', level = 60 },
    employee = { label = 'Werknemer', level = 10 }
}

Config.Points = {
    {
        id = 'centrum_office',
        label = 'Bedrijvenbalie Centrum',
        coords = vector3(-552.91, -211.26, 37.65),
        radius = 1.2
    },
    {
        id = 'haven_office',
        label = 'Havenbedrijf Balie',
        coords = vector3(1207.66, -3115.14, 5.54),
        radius = 2.0
    }
}

Config.Invoice = {
    maxAmount = 250000,
    defaultDueDays = 7
}

Config.Stash = {
    slots = 120,
    weight = 300000
}

Config.Text = {
    openKvk = 'KVK openen',
    openBusiness = 'Bedrijf openen',
    created = 'Bedrijf ingeschreven bij de KVK.',
    noMoney = 'Je hebt niet genoeg geld.',
    noAccess = 'Je hebt geen toegang tot dit bedrijf.',
    notManager = 'Je hebt geen beheerrechten.',
    invalidInput = 'Ongeldige invoer.',
    playerNotFound = 'Speler niet gevonden.',
    employeeAdded = 'Werknemer toegevoegd.',
    employeeRemoved = 'Werknemer verwijderd.',
    deposited = 'Geld gestort.',
    withdrawn = 'Geld opgenomen.',
    invoiceCreated = 'Factuur aangemaakt.',
    paidSalary = 'Loon uitbetaald.',
    noBusinesses = 'Geen bedrijven gevonden.'
}
