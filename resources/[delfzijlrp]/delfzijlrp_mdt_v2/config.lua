Config = {}

Config.Debug = false
Config.Command = 'mdt2'
Config.LegacyCommand = 'mdt'

Config.AccessJobs = {
    police = { label = 'Politie', level = 80 },
    ambulance = { label = 'Ambulance', level = 50 },
    fire = { label = 'Brandweer', level = 50 },
    mechanic = { label = 'ANWB', level = 30 },
    judge = { label = 'Rechter', level = 100 },
    lawyer = { label = 'Advocaat', level = 70 },
    customs = { label = 'Douane', level = 60 }
}

Config.SearchLimits = {
    people = 30,
    vehicles = 30,
    cases = 30,
    dispatch = 30
}

Config.FineCategories = {
    traffic = 'Verkeer',
    public_order = 'Openbare orde',
    court = 'Rechtbank',
    customs = 'Douane',
    other = 'Overig'
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot MDT v2.',
    invalidInput = 'Ongeldige invoer.',
    recordAdded = 'Record toegevoegd.',
    fineCreated = 'Boete geregistreerd.',
    notFound = 'Geen resultaten gevonden.',
    openMdt = 'MDT openen'
}
