Config = {}

Config.Command = 'restaurant'
Config.KitchenCommand = 'keuken'
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
    },
    sharazan = {
        label = 'Sharazan',
        business = 'sharazan',
        coords = vector3(-1193.45, -892.21, 13.99),
        radius = 2.0,
        blip = { sprite = 106, color = 17, scale = 0.75 },
        menu = {
            { item = 'hamburger', label = 'Hamburger', price = 10 },
            { item = 'cheeseburger', label = 'Cheeseburger', price = 12 },
            { item = 'baconburger', label = 'Baconburger', price = 14 },
            { item = 'patat', label = 'Patat', price = 6 },
            { item = 'loaded_fries', label = 'Loaded Fries', price = 13 },
            { item = 'tosti', label = 'Tosti Leroy', price = 8 },
            { item = 'milkshake', label = 'Milkshake', price = 7 },
            { item = 'cola', label = 'Cola', price = 4 }
        }
    },
    milas = {
        label = "Mila's Foodtruck",
        business = 'milas',
        coords = vector3(-1037.87, -2737.91, 20.17),
        radius = 2.0,
        blip = { sprite = 106, color = 31, scale = 0.75 },
        menu = {
            { item = 'roti_kip', label = 'Roti Kip', price = 16 },
            { item = 'broodje_pom', label = 'Broodje Pom', price = 10 },
            { item = 'broodje_kerrie', label = 'Broodje Kerrie Kip', price = 10 },
            { item = 'bara', label = 'Bara', price = 7 },
            { item = 'saoto_soep', label = 'Saoto Soep', price = 14 },
            { item = 'dawet', label = 'Dawet', price = 5 },
            { item = 'cola', label = 'Cola', price = 4 }
        }
    },
    cafe_centrum = {
        label = 'Cafe Centrum',
        business = 'cafe_centrum',
        coords = vector3(127.91, -1284.72, 29.28),
        radius = 2.0,
        blip = { sprite = 93, color = 27, scale = 0.75 },
        menu = {
            { item = 'koffie', label = 'Koffie', price = 4 },
            { item = 'thee', label = 'Thee', price = 3 },
            { item = 'cola', label = 'Cola', price = 4 },
            { item = 'bitterballen', label = 'Bitterballen', price = 8 },
            { item = 'tosti', label = 'Tosti', price = 7 },
            { item = 'chips', label = 'Chips', price = 3 }
        }
    },
    stad_lande = {
        label = 'Stad en Lande',
        business = 'stad_lande',
        coords = vector3(1985.86, 3053.92, 47.22),
        radius = 2.0,
        blip = { sprite = 93, color = 46, scale = 0.75 },
        menu = {
            { item = 'koffie', label = 'Koffie', price = 4 },
            { item = 'thee', label = 'Thee', price = 3 },
            { item = 'cola', label = 'Cola', price = 4 },
            { item = 'nachos', label = 'Nachos', price = 9 },
            { item = 'borrelplank', label = 'Borrelplank', price = 18 },
            { item = 'tosti', label = 'Tosti', price = 7 }
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
    orderReady = 'Bestelling staat klaar.',
    kitchen = 'Keukenscherm',
    delivered = 'Bestelling bezorgd.'
}
