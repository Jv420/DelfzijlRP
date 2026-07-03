Config = {}

Config.Debug = false
Config.Command = 'mdt'

Config.AllowedJobs = {
    police = true,
    ambulance = true,
    mechanic = true
}

Config.JobLabels = {
    police = 'Politie Noord-Nederland',
    ambulance = 'Ambulance Groningen',
    mechanic = 'ANWB Delfzijl'
}

Config.Permissions = {
    peopleSearch = { police = true, ambulance = true, mechanic = false },
    vehicleSearch = { police = true, ambulance = false, mechanic = true },
    createNote = { police = true, ambulance = true, mechanic = true },
    createFine = { police = true },
    markStolen = { police = true },
    renewApk = { mechanic = true },
    medicalNotes = { ambulance = true }
}

Config.FineTypes = {
    traffic = 'Verkeer',
    public_order = 'Openbare orde',
    other = 'Overig'
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot de MDT.',
    notAllowed = 'Je functie mag dit niet doen.',
    noResults = 'Geen resultaten gevonden.',
    noteCreated = 'Notitie opgeslagen.',
    fineCreated = 'Boete geregistreerd.',
    invalidInput = 'Ongeldige invoer.',
    vehicleUpdated = 'Voertuigstatus bijgewerkt.'
}
