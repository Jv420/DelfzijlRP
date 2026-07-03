Config = {}

Config.Debug = false
Config.UseBlips = true
Config.Currency = '€'

Config.Banks = {
    vector3(149.87, -1040.78, 29.37),
    vector3(-1212.98, -330.84, 37.79),
    vector3(-2962.58, 482.63, 15.70),
    vector3(314.19, -278.62, 54.17),
    vector3(-351.53, -49.53, 49.04),
    vector3(1175.06, 2706.64, 38.09),
    vector3(-112.03, 6469.21, 31.63)
}

Config.ATMModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`
}

Config.Limits = {
    minAmount = 1,
    maxDeposit = 100000,
    maxWithdraw = 50000,
    maxTransfer = 100000
}

Config.Text = {
    bank = 'Bank openen',
    atm = 'ATM openen',
    invalidAmount = 'Ongeldig bedrag.',
    notEnoughCash = 'Je hebt niet genoeg contant geld.',
    notEnoughBank = 'Je hebt niet genoeg geld op je bank.',
    playerNotFound = 'Speler niet gevonden.',
    samePlayer = 'Je kunt geen geld naar jezelf overmaken.',
    depositSuccess = 'Geld gestort.',
    withdrawSuccess = 'Geld opgenomen.',
    transferSuccess = 'Overschrijving gelukt.',
    receivedTransfer = 'Je hebt een overschrijving ontvangen.'
}
