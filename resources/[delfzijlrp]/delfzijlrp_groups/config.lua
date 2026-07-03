Config = {}

Config.Debug = false
Config.Command = 'groep'
Config.CreatePrice = 10000

Config.Office = {
    label = 'Organisatiebalie Delfzijl',
    coords = vector3(-552.34, -191.84, 38.22),
    radius = 2.0,
    blip = { sprite = 475, color = 27, scale = 0.75 }
}

Config.GroupTypes = {
    club = 'Club',
    community = 'Community',
    company = 'Bedrijfsteam',
    crew = 'Crew',
    family = 'Familie',
    other = 'Overig'
}

Config.Ranks = {
    owner = { label = 'Eigenaar', level = 100 },
    leader = { label = 'Leider', level = 80 },
    manager = { label = 'Manager', level = 60 },
    member = { label = 'Lid', level = 10 }
}

Config.Stash = {
    slots = 80,
    weight = 200000
}

Config.Locations = {
    {
        id = 'haven_hangout',
        label = 'Haven ontmoetingsplek',
        coords = vector3(-807.04, -1311.71, 5.0),
        radius = 2.0
    },
    {
        id = 'centrum_hangout',
        label = 'Centrum ontmoetingsplek',
        coords = vector3(198.72, -935.31, 30.69),
        radius = 2.0
    }
}

Config.Text = {
    openOffice = 'Organisatiebalie openen',
    openLocation = 'Groepspunt openen',
    created = 'Groep aangemaakt.',
    noMoney = 'Je hebt niet genoeg geld.',
    noAccess = 'Je hebt geen toegang.',
    notManager = 'Je hebt geen beheerrechten.',
    invalidInput = 'Ongeldige invoer.',
    playerNotFound = 'Speler niet gevonden.',
    memberAdded = 'Lid toegevoegd.',
    memberRemoved = 'Lid verwijderd.',
    deposited = 'Geld gestort.',
    withdrawn = 'Geld opgenomen.',
    noGroups = 'Je zit nog niet in een groep.'
}
