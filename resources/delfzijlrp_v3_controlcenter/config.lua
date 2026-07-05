Config = {}

Config.Command = 'drcc'
Config.AdminGroups = {
    owner = true,
    admin = true,
    superadmin = true
}

Config.Discord = {
    enabled = true,
    webhook = '',
    botName = 'Delfzijl RP Control Center'
}

Config.DefaultGarage = 'centrum'

Config.RewardPresets = {
    starter = {
        label = 'Starterpakket',
        money = 15000,
        items = {
            { name = 'phone', count = 1 },
            { name = 'bread', count = 5 },
            { name = 'water', count = 5 },
            { name = 'buskaartje', count = 1 }
        }
    },
    garage = {
        label = 'Garagepakket',
        money = 25000,
        items = {
            { name = 'repairkit', count = 2 },
            { name = 'cleaningkit', count = 2 }
        }
    }
}

Config.Text = {
    noAccess = 'Je hebt geen toegang tot het Control Center.',
    playerNotFound = 'Speler niet gevonden.',
    done = 'Actie uitgevoerd.',
    invalid = 'Ongeldige invoer.',
    missingItem = 'Item bestaat niet in ox_inventory.',
    vehicleGiven = 'Voertuig cadeau gegeven.',
    announcement = 'Stadsbericht verstuurd.'
}
