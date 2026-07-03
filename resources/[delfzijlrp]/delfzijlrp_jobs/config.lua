Config = {}

Config.Debug = false
Config.Command = 'werk'
Config.UseBlips = true

Config.JobCenter = {
    label = 'UWV Delfzijl',
    coords = vector3(-268.86, -955.32, 31.22),
    radius = 2.0,
    blip = { sprite = 407, color = 3, scale = 0.75 }
}

Config.Jobs = {
    garbage = {
        label = 'Vuilnisdienst',
        item = 'recyclable_material',
        reward = { min = 250, max = 450 },
        workTime = 6000,
        start = vector3(-321.54, -1545.86, 31.02),
        points = {
            vector3(-354.35, -1560.12, 25.22),
            vector3(-429.26, -1728.14, 19.79),
            vector3(-573.94, -1773.89, 23.18)
        },
        blip = { sprite = 318, color = 25, scale = 0.7 }
    },
    postnl = {
        label = 'PostNL Bezorger',
        item = 'parcel',
        reward = { min = 200, max = 380 },
        workTime = 5000,
        start = vector3(78.94, 111.88, 81.17),
        points = {
            vector3(8.36, -243.63, 47.66),
            vector3(-42.39, -58.27, 63.68),
            vector3(-147.96, -168.12, 43.62)
        },
        blip = { sprite = 478, color = 5, scale = 0.7 }
    },
    fisherman = {
        label = 'Visser',
        item = 'fish',
        reward = { min = 150, max = 320 },
        workTime = 7000,
        start = vector3(-1598.69, 5201.38, 4.31),
        points = {
            vector3(-1612.58, 5262.27, 3.97),
            vector3(-1604.92, 5256.63, 3.97),
            vector3(-1597.29, 5250.41, 3.97)
        },
        blip = { sprite = 68, color = 3, scale = 0.7 }
    },
    lumberjack = {
        label = 'Houthakker',
        item = 'wood',
        reward = { min = 180, max = 350 },
        workTime = 6500,
        start = vector3(-567.61, 5253.05, 70.49),
        points = {
            vector3(-553.14, 5370.37, 70.36),
            vector3(-510.53, 5389.42, 73.71),
            vector3(-486.81, 5395.05, 77.04)
        },
        blip = { sprite = 237, color = 2, scale = 0.7 }
    },
    farmer = {
        label = 'Boer',
        item = 'vegetables',
        reward = { min = 170, max = 330 },
        workTime = 6000,
        start = vector3(2026.78, 4987.64, 42.1),
        points = {
            vector3(2035.14, 4965.72, 41.1),
            vector3(2046.51, 4976.93, 41.08),
            vector3(2057.93, 4988.12, 41.1)
        },
        blip = { sprite = 85, color = 2, scale = 0.7 }
    },
    miner = {
        label = 'Mijnwerker',
        item = 'ore',
        reward = { min = 220, max = 420 },
        workTime = 7500,
        start = vector3(2952.06, 2747.41, 43.42),
        points = {
            vector3(2976.28, 2741.61, 43.5),
            vector3(2994.12, 2750.42, 43.4),
            vector3(3001.54, 2765.89, 43.5)
        },
        blip = { sprite = 618, color = 46, scale = 0.7 }
    }
}

Config.Text = {
    openJobCenter = 'UWV openen',
    startJob = 'Werk starten',
    stopJob = 'Werk stoppen',
    doWork = 'Werk uitvoeren',
    sellItems = 'Goederen inleveren',
    jobStarted = 'Je bent begonnen met werken.',
    jobStopped = 'Je bent gestopt met werken.',
    workDone = 'Werk voltooid.',
    noItems = 'Je hebt geen goederen om in te leveren.',
    paid = 'Je hebt je beloning ontvangen.',
    invalidJob = 'Onbekende baan.'
}
