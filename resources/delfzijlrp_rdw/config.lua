Config = {}

Config.Debug = false
Config.Command = 'rdw'
Config.AdminCommand = 'rdwadmin'
Config.ItemName = 'kentekenbewijs'

Config.RDWOffice = {
    label = 'RDW Delfzijl',
    coords = vector3(-42.67, -1098.22, 26.42),
    radius = 2.0,
    blip = { sprite = 225, color = 46, scale = 0.8 }
}

Config.Prices = {
    register = 750,
    replaceDocument = 250,
    customPlate = 100000,
    transfer = 1500,
    plateReplace = 500,
    insuranceWA = 1200,
    insuranceWAPLUS = 2500,
    insuranceAllRisk = 5000,
    apk = 750
}

Config.Plate = {
    maxAttempts = 50,
    patterns = {
        'LL-NNN-L',
        'L-NNN-LL',
        'NN-LL-NN',
        'NNN-LL-N',
        'LL-NN-LL'
    },
    blocked = {
        ['NSB'] = true,
        ['KKK'] = true,
        ['SS'] = true,
        ['SD'] = true
    }
}

Config.ValidDays = {
    insurance = 30,
    apk = 14
}

Config.AllowedJobs = {
    police = true,
    mechanic = true,
    government = true
}

Config.Text = {
    open = 'RDW openen',
    noVehicle = 'Geen voertuig gevonden.',
    noMoney = 'Je hebt niet genoeg geld.',
    registered = 'Voertuig geregistreerd bij de RDW.',
    transferred = 'Voertuig overgeschreven.',
    customSet = 'Persoonlijk kenteken ingesteld.',
    notOwner = 'Dit voertuig staat niet op jouw naam.',
    notFound = 'Geen RDW-registratie gevonden.',
    updated = 'RDW gegevens bijgewerkt.',
    invalid = 'Ongeldige invoer.'
}
