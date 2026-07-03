Config = {}

Config.Debug = false
Config.Command = 'meldkamer'
Config.ReportCommand = '112'
Config.PanicCommand = 'panic'

Config.AllowedJobs = {
    police = true,
    ambulance = true,
    mechanic = true,
    taxi = true
}

Config.Services = {
    police = { label = 'Politie', jobs = { police = true }, icon = 'shield-halved' },
    ambulance = { label = 'Ambulance', jobs = { ambulance = true }, icon = 'truck-medical' },
    mechanic = { label = 'ANWB', jobs = { mechanic = true }, icon = 'screwdriver-wrench' },
    taxi = { label = 'Taxi', jobs = { taxi = true }, icon = 'taxi' }
}

Config.ReportTypes = {
    emergency = { label = '112 Spoedmelding', service = 'police' },
    medical = { label = 'Medische melding', service = 'ambulance' },
    roadside = { label = 'Pechhulp', service = 'mechanic' },
    taxi = { label = 'Taxi oproep', service = 'taxi' }
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot de meldkamer.',
    reportSent = 'Melding verzonden.',
    reportAccepted = 'Melding aangenomen.',
    reportClosed = 'Melding afgesloten.',
    noReports = 'Geen openstaande meldingen.',
    invalidInput = 'Ongeldige invoer.',
    panicSent = 'Paniekknop geactiveerd.'
}
