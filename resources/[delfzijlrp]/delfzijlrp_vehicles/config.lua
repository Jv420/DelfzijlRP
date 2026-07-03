Config = {}

Config.Debug = false
Config.ResourceName = 'delfzijlrp_vehicles'

Config.RDW = {
    defaultApkDays = 365,
    defaultInsuranceDays = 30,
    defaultInsuranceType = 'WA',
    vinPrefix = 'DRP',
    mileageTick = 30000
}

Config.Keys = {
    command = 'autosleutels',
    giveDistance = 5.0,
    allowedServiceJobs = {
        police = true,
        ambulance = true,
        mechanic = true
    }
}

Config.InsuranceTypes = {
    WA = { label = 'WA', price = 500 },
    WAPLUS = { label = 'WA+', price = 1200 },
    ALLRISK = { label = 'All Risk', price = 2500 }
}

Config.Text = {
    noVehicle = 'Geen voertuig dichtbij gevonden.',
    notOwner = 'Dit voertuig staat niet op jouw naam.',
    noKeys = 'Je hebt geen sleutels van dit voertuig.',
    keysGiven = 'Sleutel gegeven.',
    keysReceived = 'Je hebt voertuigsleutels ontvangen.',
    playerNotFound = 'Speler niet gevonden of te ver weg.',
    rdwCreated = 'RDW-record aangemaakt.',
    rdwMissing = 'Geen RDW-record gevonden.',
    transferred = 'Voertuig overgeschreven.',
    apkRenewed = 'APK vernieuwd.',
    insuranceRenewed = 'Verzekering vernieuwd.',
    stolenMarked = 'Voertuigstatus aangepast.'
}
