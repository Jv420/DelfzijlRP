Config = {}

Config.Debug = false
Config.Command = 'rechtbank'
Config.JobAccess = {
    judge = true,
    lawyer = true,
    police = true
}

Config.CourtHouse = {
    label = 'Rechtbank Delfzijl',
    coords = vector3(240.13, -1090.42, 29.29),
    radius = 2.0,
    blip = { sprite = 419, color = 46, scale = 0.8 }
}

Config.CaseStatuses = {
    open = 'Open',
    scheduled = 'Zitting gepland',
    closed = 'Gesloten',
    dismissed = 'Geseponeerd'
}

Config.CaseTypes = {
    criminal = 'Strafzaak',
    civil = 'Civiele zaak',
    traffic = 'Verkeerszaak',
    appeal = 'Bezwaar/beroep',
    other = 'Overig'
}

Config.DefaultHearingDuration = 30

Config.Text = {
    openCourt = 'Rechtbank openen',
    noAccess = 'Je hebt geen toegang tot het rechtbankmenu.',
    caseCreated = 'Dossier aangemaakt.',
    caseUpdated = 'Dossier bijgewerkt.',
    hearingCreated = 'Zitting gepland.',
    invalidInput = 'Ongeldige invoer.',
    notFound = 'Niet gevonden.',
    noCases = 'Geen dossiers gevonden.'
}
