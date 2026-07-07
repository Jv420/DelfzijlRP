Config = {}

Config.Command = 'restaurant'
Config.KitchenCommand = 'keuken'
Config.DeliveryCommand = 'bezorging'
Config.StockCommand = 'voorraad'
Config.Debug = false
Config.DeliveryFee = 25
Config.DefaultIngredientStock = 250

Config.Restaurants = {
    alanya = {
        label = 'Alanya', business = 'alanya', coords = vector3(12.12, -1605.45, 29.38), radius = 2.0,
        blip = { sprite = 106, color = 47, scale = 0.75 },
        menu = {
            { item = 'broodje_doner', label = 'Broodje Doner', price = 12 }, { item = 'broodje_kip', label = 'Broodje Kip', price = 12 },
            { item = 'kapsalon_klein', label = 'Kleine Kapsalon', price = 14 }, { item = 'kapsalon_groot', label = 'Grote Kapsalon', price = 22 },
            { item = 'lahmacun', label = 'Lahmacun', price = 10 }, { item = 'pizza_doner', label = 'Pizza Doner', price = 18 },
            { item = 'pizza_margherita', label = 'Pizza Margherita', price = 14 }, { item = 'ayran', label = 'Ayran', price = 4 },
            { item = 'cola', label = 'Cola', price = 4 }
        }
    },
    sharazan = {
        label = 'Sharazan', business = 'sharazan', coords = vector3(-1193.45, -892.21, 13.99), radius = 2.0,
        blip = { sprite = 106, color = 17, scale = 0.75 },
        menu = {
            { item = 'hamburger', label = 'Hamburger', price = 10 }, { item = 'cheeseburger', label = 'Cheeseburger', price = 12 },
            { item = 'baconburger', label = 'Baconburger', price = 14 }, { item = 'patat', label = 'Patat', price = 6 },
            { item = 'loaded_fries', label = 'Loaded Fries', price = 13 }, { item = 'tosti', label = 'Tosti Leroy', price = 8 },
            { item = 'milkshake', label = 'Milkshake', price = 7 }, { item = 'cola', label = 'Cola', price = 4 }
        }
    },
    milas = {
        label = "Mila's Foodtruck", business = 'milas', coords = vector3(-1037.87, -2737.91, 20.17), radius = 2.0,
        blip = { sprite = 106, color = 31, scale = 0.75 },
        menu = {
            { item = 'roti_kip', label = 'Roti Kip', price = 16 }, { item = 'broodje_pom', label = 'Broodje Pom', price = 10 },
            { item = 'broodje_kerrie', label = 'Broodje Kerrie Kip', price = 10 }, { item = 'bara', label = 'Bara', price = 7 },
            { item = 'saoto_soep', label = 'Saoto Soep', price = 14 }, { item = 'dawet', label = 'Dawet', price = 5 },
            { item = 'cola', label = 'Cola', price = 4 }
        }
    },
    cafe_centrum = {
        label = 'Cafe Centrum', business = 'cafe_centrum', coords = vector3(127.91, -1284.72, 29.28), radius = 2.0,
        blip = { sprite = 93, color = 27, scale = 0.75 },
        menu = {
            { item = 'koffie', label = 'Koffie', price = 4 }, { item = 'thee', label = 'Thee', price = 3 },
            { item = 'cola', label = 'Cola', price = 4 }, { item = 'bitterballen', label = 'Bitterballen', price = 8 },
            { item = 'tosti', label = 'Tosti', price = 7 }, { item = 'chips', label = 'Chips', price = 3 }
        }
    },
    stad_lande = {
        label = 'Stad en Lande', business = 'stad_lande', coords = vector3(1985.86, 3053.92, 47.22), radius = 2.0,
        blip = { sprite = 93, color = 46, scale = 0.75 },
        menu = {
            { item = 'koffie', label = 'Koffie', price = 4 }, { item = 'thee', label = 'Thee', price = 3 },
            { item = 'cola', label = 'Cola', price = 4 }, { item = 'nachos', label = 'Nachos', price = 9 },
            { item = 'borrelplank', label = 'Borrelplank', price = 18 }, { item = 'tosti', label = 'Tosti', price = 7 }
        }
    }
}

Config.Recipes = {
    broodje_doner = { brood = 1, doner = 1, sla = 1, saus = 1 }, broodje_kip = { brood = 1, kip = 1, sla = 1, saus = 1 },
    kapsalon_klein = { friet = 1, doner = 1, kaas = 1, sla = 1, saus = 1 }, kapsalon_groot = { friet = 2, doner = 2, kaas = 1, sla = 1, saus = 1 },
    lahmacun = { deeg = 1, vleesmix = 1, sla = 1 }, pizza_doner = { deeg = 1, saus_tomaat = 1, kaas = 1, doner = 1 }, pizza_margherita = { deeg = 1, saus_tomaat = 1, kaas = 1 },
    hamburger = { brood = 1, burger = 1, sla = 1, saus = 1 }, cheeseburger = { brood = 1, burger = 1, kaas = 1, saus = 1 }, baconburger = { brood = 1, burger = 1, bacon = 1, kaas = 1 },
    patat = { friet = 1 }, loaded_fries = { friet = 2, kaas = 1, saus = 1 }, tosti = { brood = 2, kaas = 1 }, milkshake = { melk = 1, suiker = 1 },
    roti_kip = { roti = 1, kip = 1, aardappel = 1 }, broodje_pom = { brood = 1, pom = 1 }, broodje_kerrie = { brood = 1, kip = 1, kerrie = 1 }, bara = { bara_deeg = 1 }, saoto_soep = { soep = 1, kip = 1 }, dawet = { melk = 1, siroop = 1 },
    koffie = { koffiebonen = 1 }, thee = { theezakje = 1 }, bitterballen = { bitterbal_mix = 1 }, chips = { chips_zak = 1 }, nachos = { nachos_chips = 1, kaas = 1 }, borrelplank = { kaas = 1, brood = 1, snacks = 1 },
    ayran = {}, cola = {}
}

Config.Text = {
    open = 'Restaurant openen', bought = 'Bestelling betaald.', noMoney = 'Niet genoeg geld.', missingItem = 'Item bestaat nog niet in ox_inventory.', invalid = 'Ongeldige keuze.',
    orderCreated = 'Bestelling aangemaakt.', orderReady = 'Bestelling staat klaar.', kitchen = 'Keukenscherm', delivered = 'Bestelling bezorgd.', delivery = 'Bezorging', accepted = 'Bezorging aangenomen.', completed = 'Bezorging afgerond.',
    stock = 'Voorraad', noStock = 'Niet genoeg voorraad voor dit gerecht.', stockAdded = 'Voorraad aangevuld.'
}
