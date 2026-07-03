Config = {}

Config.Debug = false
Config.Command = 'bank'
Config.ATMCommand = 'atm'
Config.CreateAccountOnJoin = true

Config.Bank = {
    name = 'Delfzijl Bank',
    ibanPrefix = 'DRP',
    transactionLimit = 250000,
    transferFee = 5
}

Config.BankLocations = {
    { label = 'Delfzijl Bank Centrum', coords = vector3(149.91, -1040.74, 29.37), blip = { sprite = 108, color = 2, scale = 0.7 } },
    { label = 'Delfzijl Bank Haven', coords = vector3(-1212.98, -330.84, 37.78), blip = { sprite = 108, color = 2, scale = 0.7 } }
}

Config.ATMModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`
}

Config.Text = {
    openBank = 'Bank openen',
    openATM = 'ATM openen',
    accountCreated = 'Bankrekening aangemaakt.',
    invalidInput = 'Ongeldige invoer.',
    noMoney = 'Onvoldoende saldo.',
    transferDone = 'Overschrijving voltooid.',
    depositDone = 'Geld gestort.',
    withdrawDone = 'Geld opgenomen.',
    accountNotFound = 'Rekening niet gevonden.',
    limitExceeded = 'Bedrag is boven de transactielimiet.'
}
