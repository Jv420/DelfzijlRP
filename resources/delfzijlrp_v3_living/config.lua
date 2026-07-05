Config = {}

Config.Debug = false
Config.Command = 'living'
Config.DailyCommand = 'dagtaak'

Config.City = {
    name = 'Delfzijl RP',
    slogan = 'Living Netherlands',
    center = vector3(-544.91, -211.26, 37.65)
}

Config.Districts = {
    {
        id = 'gemeente',
        label = 'Gemeente & Burgerzaken',
        coords = vector3(-544.91, -211.26, 37.65),
        blip = { sprite = 280, color = 3, scale = 0.7 },
        tasks = {
            { id = 'id_check', label = 'Controleer je papieren', reward = 125, command = 'geefidkaart' },
            { id = 'rijbewijs', label = 'Vraag je rijbewijs aan', reward = 150, command = 'geefrijbewijs' }
        }
    },
    {
        id = 'haven',
        label = 'Haven van Delfzijl',
        coords = vector3(1207.66, -3115.14, 5.54),
        blip = { sprite = 455, color = 38, scale = 0.8 },
        tasks = {
            { id = 'container', label = 'Container administratie controleren', reward = 300, command = 'haven' },
            { id = 'import', label = 'Import/export melding maken', reward = 350, command = 'havenwerk' }
        }
    },
    {
        id = 'visserij',
        label = 'Visserij & Visafslag',
        coords = vector3(-1598.25, 5200.12, 4.31),
        blip = { sprite = 410, color = 3, scale = 0.7 },
        tasks = {
            { id = 'dagvangst', label = 'Dagvangst registreren', reward = 250, command = 'vis' },
            { id = 'visafslag', label = 'Vis naar afslag brengen', reward = 275, command = 'visafslag' }
        }
    },
    {
        id = 'boerderij',
        label = 'Boerderij & Platteland',
        coords = vector3(2440.82, 4970.33, 46.81),
        blip = { sprite = 285, color = 25, scale = 0.7 },
        tasks = {
            { id = 'melkroute', label = 'Melkroute voorbereiden', reward = 225, command = 'boerderij' },
            { id = 'oogst', label = 'Oogstplanning bekijken', reward = 225, command = 'oogst' }
        }
    },
    {
        id = 'horeca',
        label = 'Horeca & Terrassen',
        coords = vector3(198.34, -934.89, 30.69),
        blip = { sprite = 93, color = 46, scale = 0.7 },
        tasks = {
            { id = 'dagmenu', label = 'Dagmenu controleren', reward = 100, command = 'horeca' },
            { id = 'eten', label = 'Eettentjes bezoeken', reward = 100, command = 'eten' }
        }
    },
    {
        id = 'mobiliteit',
        label = 'Mobiliteit & Vervoer',
        coords = vector3(895.72, -179.25, 74.70),
        blip = { sprite = 198, color = 5, scale = 0.7 },
        tasks = {
            { id = 'buskaart', label = 'Buskaartje kopen', reward = 75, command = 'buskaartje' },
            { id = 'taxi', label = 'Taxi rit plannen', reward = 100, command = 'taxirit' }
        }
    }
}

Config.Events = {
    { id = 'markt', label = 'Weekmarkt Delfzijl', description = 'Kramen, eten, handel en kleine opdrachten.' },
    { id = 'kermis', label = 'Kermis op het plein', description = 'Tijdelijke attracties en gezelligheid.' },
    { id = 'delfsail', label = 'DelfSail RP Event', description = 'Haven, boten, horeca en politiebegeleiding.' },
    { id = 'koningsdag', label = 'Koningsdag', description = 'Oranje markt en stadsevents.' }
}

Config.Text = {
    open = 'Living Netherlands openen',
    taskDone = 'Dagtaak voltooid.',
    taskAlready = 'Je hebt vandaag al een dagtaak gedaan.',
    waypoint = 'Waypoint ingesteld.',
    noTask = 'Geen taak gevonden.'
}
