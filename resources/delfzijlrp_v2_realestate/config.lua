Config = {}

Config.Debug = false
Config.Command = 'vastgoed'

Config.Office = {
    label = 'Delfzijl Vastgoed',
    coords = vector3(-138.44, -633.91, 168.82),
    radius = 2.0,
    blip = { sprite = 374, color = 46, scale = 0.75 }
}

Config.Properties = {
    { id = 'biz_001', label = 'Winkelruimte Centrum', coords = vector3(116.18, -168.12, 54.5), price = 175000, rent = 5500, type = 'Bedrijfsruimte' },
    { id = 'biz_002', label = 'Kantoorruimte Arcadius', coords = vector3(-1579.65, -565.82, 108.52), price = 325000, rent = 9000, type = 'Kantoor' },
    { id = 'biz_003', label = 'Garagebox Industrieterrein', coords = vector3(941.64, -975.12, 39.50), price = 220000, rent = 7500, type = 'Werkplaats' },
    { id = 'vast_001', label = 'Appartement Havenzicht', coords = vector3(-803.06, -1311.05, 5.0), price = 185000, rent = 5500, type = 'Woning' }
}

Config.Text = {
    open = 'Vastgoed openen',
    bought = 'Vastgoed gekocht.',
    sold = 'Vastgoed verkocht.',
    rented = 'Huurcontract aangemaakt.',
    noMoney = 'Je hebt niet genoeg geld.',
    notOwner = 'Dit vastgoed staat niet op jouw naam.',
    alreadyOwned = 'Dit vastgoed is al verkocht.',
    invalid = 'Ongeldige keuze.'
}
