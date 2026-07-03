Config = {}

Config.Debug = false
Config.Command = 'gemeente'
Config.AdminCommand = 'gemeenteraad'
Config.CityJob = 'government'

Config.CityHall = {
    label = 'Gemeentehuis Delfzijl',
    coords = vector3(-544.72, -204.15, 38.22),
    radius = 2.0,
    blip = { sprite = 419, color = 3, scale = 0.8 }
}

Config.City = {
    name = 'Gemeente Delfzijl',
    mayorTitle = 'Burgemeester',
    startingBalance = 500000
}

Config.Services = {
    id_copy = { label = 'Kopie Delfzijl ID', price = 150 },
    address_change = { label = 'Adreswijziging registreren', price = 250 },
    permit_request = { label = 'Vergunning aanvragen', price = 500 },
    business_check = { label = 'Bedrijfscontrole aanvragen', price = 750 }
}

Config.PermitTypes = {
    taxi = 'Taxi vergunning',
    transport = 'Transport vergunning',
    market = 'Marktkraam vergunning',
    event = 'Evenementen vergunning',
    port = 'Havenactiviteiten vergunning',
    horeca = 'Horeca vergunning',
    business = 'Bedrijfsvergunning'
}

Config.Departments = {
    civil = 'Burgerzaken',
    finance = 'Gemeentefinanciën',
    works = 'Openbare werken',
    port = 'Havenbeheer',
    permits = 'Vergunningen'
}

Config.PublicWorks = {
    streetlight = 'Straatverlichting melding',
    road = 'Wegonderhoud melding',
    bridge = 'Brug/storing melding',
    harbor = 'Haventerrein melding'
}

Config.Text = {
    openCityHall = 'Gemeentehuis openen',
    noAccess = 'Je hebt geen gemeentelijke beheerrechten.',
    noMoney = 'Je hebt niet genoeg geld.',
    paid = 'Gemeenteservice betaald.',
    permitCreated = 'Vergunningaanvraag ingediend.',
    permitUpdated = 'Vergunning bijgewerkt.',
    reportCreated = 'Melding openbare werken ingediend.',
    treasuryUpdated = 'Gemeentekas bijgewerkt.',
    invalidInput = 'Ongeldige invoer.',
    noData = 'Geen gegevens gevonden.'
}
