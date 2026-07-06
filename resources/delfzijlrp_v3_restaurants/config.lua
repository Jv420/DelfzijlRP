Config = {}

Config.Command = 'restaurant'
Config.Debug = false

Config.Restaurants = {
    alanya = {
        label = 'Alanya',
        business = 'alanya',
        coords = vector3(12.12, -1605.45, 29.38),
        radius = 2.0,
        blip = { sprite = 106, color = 47, scale = 0.75 },
        menu = {
            { item = 'broodje_doner', label = 'Broodje Doner', price = 12 },
            { item = 'broodje_kip', label = 'Broodje Kip', price = 12 },
            { item = 'kapsalon_klein', label = 'Kleine Kapsalon', price = 14 },
            { item = 'kapsalon_groot', label = 'Grote Kapsalon', price = 22 },
            { item = 'lahmacun', label = 'Lahmacun', price = 10 },
            { item = 'pizza_doner', label = 'Pizza Doner', price = 18 },
            { item = 'pizza_margherita', label = 'Pizza Margherita', price = 14 },
            { item = 'ayran', label = 'Ayran', price = 4 },
            { item = 'cola', label = 'Cola', price = 4 }
        }
    }
}

Config.Text = {
    open = 'Restaurant openen',
    bought = 'Bestelling betaald.',
    noMoney = 'Niet genoeg geld.',
    missingItem = 'Item bestaat nog niet in ox_inventory.',
    invalid = 'Ongeldige keuze.',
    orderCreated = 'Bestelling aangemaakt.',
    orderReady = 'Bestelling staat klaar.'
}
