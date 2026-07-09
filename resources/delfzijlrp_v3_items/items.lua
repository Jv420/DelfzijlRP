-- DelfzijlRP v3 - ox_inventory items
-- Kopieer de inhoud van deze tabel naar ox_inventory/data/items.lua
-- of merge alleen de items die je nog mist.

return {
    -- ==========================================
    -- Gemeente / documenten
    -- ==========================================
    ['idkaart'] = {
        label = 'ID-kaart',
        weight = 50,
        stack = false,
        close = true,
        description = 'Officiële Delfzijl RP identiteitskaart.',
        client = { image = 'idkaart.png' }
    },

    ['paspoort'] = {
        label = 'Paspoort',
        weight = 50,
        stack = false,
        close = true,
        description = 'Officieel paspoort van Gemeente Delfzijl.',
        client = { image = 'paspoort.png' }
    },

    ['rijbewijs'] = {
        label = 'Rijbewijs B',
        weight = 50,
        stack = false,
        close = true,
        description = 'Rijbewijs categorie B.',
        client = { image = 'rijbewijs.png' }
    },

    ['motorrijbewijs'] = {
        label = 'Motorrijbewijs A',
        weight = 50,
        stack = false,
        close = true,
        description = 'Rijbewijs categorie A.',
        client = { image = 'motorrijbewijs.png' }
    },

    ['vrachtwagenrijbewijs'] = {
        label = 'Vrachtwagenrijbewijs C',
        weight = 50,
        stack = false,
        close = true,
        description = 'Rijbewijs categorie C.',
        client = { image = 'vrachtwagenrijbewijs.png' }
    },

    ['busrijbewijs'] = {
        label = 'Busrijbewijs D',
        weight = 50,
        stack = false,
        close = true,
        description = 'Rijbewijs categorie D.',
        client = { image = 'busrijbewijs.png' }
    },

    ['vaarbewijs'] = {
        label = 'Vaarbewijs',
        weight = 50,
        stack = false,
        close = true,
        description = 'Officieel vaarbewijs.',
        client = { image = 'vaarbewijs.png' }
    },

    ['buskaartje'] = {
        label = 'Buskaartje',
        weight = 10,
        stack = true,
        close = true,
        description = 'Dagkaart voor openbaar vervoer in Delfzijl.',
        client = { image = 'buskaartje.png' }
    },

    ['visvergunning'] = {
        label = 'Visvergunning',
        weight = 50,
        stack = false,
        close = true,
        description = 'Vergunning om legaal te vissen.',
        client = { image = 'visvergunning.png' }
    },

    ['werkvergunning'] = {
        label = 'Werkvergunning',
        weight = 50,
        stack = false,
        close = true,
        description = 'Werkvergunning van Gemeente Delfzijl.',
        client = { image = 'werkvergunning.png' }
    },

    ['bouwvergunning'] = {
        label = 'Bouwvergunning',
        weight = 50,
        stack = false,
        close = true,
        description = 'Vergunning voor bouw- en verbouwwerkzaamheden.',
        client = { image = 'bouwvergunning.png' }
    },

    ['marktvergunning'] = {
        label = 'Marktvergunning',
        weight = 50,
        stack = false,
        close = true,
        description = 'Vergunning voor verkoop op de markt.',
        client = { image = 'marktvergunning.png' }
    },

    ['uittreksel_brp'] = {
        label = 'Uittreksel BRP',
        weight = 50,
        stack = false,
        close = true,
        description = 'Uittreksel uit de basisregistratie personen.',
        client = { image = 'uittreksel_brp.png' }
    },

    ['geboorteakte'] = {
        label = 'Geboorteakte',
        weight = 50,
        stack = false,
        close = true,
        description = 'Officiële geboorteakte.',
        client = { image = 'geboorteakte.png' }
    },

    ['verhuisverklaring'] = {
        label = 'Verhuisverklaring',
        weight = 50,
        stack = false,
        close = true,
        description = 'Verklaring voor verhuizing binnen Delfzijl RP.',
        client = { image = 'verhuisverklaring.png' }
    },

    -- ==========================================
    -- Restaurant eindproducten
    -- ==========================================
    ['broodje_doner'] = {
        label = 'Broodje Doner',
        weight = 220,
        stack = true,
        close = true,
        consume = 1,
        description = 'Vers broodje met doner, salade en saus.',
        client = { image = 'broodje_doner.png', status = { hunger = 220000 }, anim = 'eating', prop = 'burger' }
    },

    ['broodje_kip'] = {
        label = 'Broodje Kip',
        weight = 220,
        stack = true,
        close = true,
        consume = 1,
        description = 'Broodje kip met salade en saus.',
        client = { image = 'broodje_kip.png', status = { hunger = 220000 }, anim = 'eating', prop = 'burger' }
    },

    ['kapsalon_klein'] = {
        label = 'Kleine Kapsalon',
        weight = 350,
        stack = true,
        close = true,
        consume = 1,
        description = 'Kleine kapsalon met friet, vlees, kaas en salade.',
        client = { image = 'kapsalon_klein.png', status = { hunger = 300000 }, anim = 'eating', prop = 'burger' }
    },

    ['kapsalon_groot'] = {
        label = 'Grote Kapsalon',
        weight = 550,
        stack = true,
        close = true,
        consume = 1,
        description = 'Grote kapsalon met extra vlees en friet.',
        client = { image = 'kapsalon_groot.png', status = { hunger = 450000 }, anim = 'eating', prop = 'burger' }
    },

    ['lahmacun'] = {
        label = 'Lahmacun',
        weight = 240,
        stack = true,
        close = true,
        consume = 1,
        description = 'Turkse pizza met vleesmix en salade.',
        client = { image = 'lahmacun.png', status = { hunger = 260000 }, anim = 'eating', prop = 'burger' }
    },

    ['pizza_doner'] = {
        label = 'Pizza Doner',
        weight = 600,
        stack = true,
        close = true,
        consume = 1,
        description = 'Pizza met doner en kaas.',
        client = { image = 'pizza_doner.png', status = { hunger = 430000 }, anim = 'eating', prop = 'burger' }
    },

    ['pizza_margherita'] = {
        label = 'Pizza Margherita',
        weight = 520,
        stack = true,
        close = true,
        consume = 1,
        description = 'Klassieke pizza met tomatensaus en kaas.',
        client = { image = 'pizza_margherita.png', status = { hunger = 380000 }, anim = 'eating', prop = 'burger' }
    },

    ['ayran'] = {
        label = 'Ayran',
        weight = 250,
        stack = true,
        close = true,
        consume = 1,
        description = 'Frisse Turkse yoghurtdrank.',
        client = { image = 'ayran.png', status = { thirst = 250000 }, anim = 'drinking', prop = 'drink' }
    },

    ['cola'] = {
        label = 'Cola',
        weight = 330,
        stack = true,
        close = true,
        consume = 1,
        description = 'Blikje cola.',
        client = { image = 'cola.png', status = { thirst = 220000 }, anim = 'drinking', prop = 'drink' }
    },

    ['hamburger'] = {
        label = 'Hamburger',
        weight = 250,
        stack = true,
        close = true,
        consume = 1,
        description = 'Hamburger van Sharazan.',
        client = { image = 'hamburger.png', status = { hunger = 260000 }, anim = 'eating', prop = 'burger' }
    },

    ['cheeseburger'] = {
        label = 'Cheeseburger',
        weight = 270,
        stack = true,
        close = true,
        consume = 1,
        description = 'Burger met kaas.',
        client = { image = 'cheeseburger.png', status = { hunger = 290000 }, anim = 'eating', prop = 'burger' }
    },

    ['baconburger'] = {
        label = 'Baconburger',
        weight = 300,
        stack = true,
        close = true,
        consume = 1,
        description = 'Burger met bacon en kaas.',
        client = { image = 'baconburger.png', status = { hunger = 330000 }, anim = 'eating', prop = 'burger' }
    },

    ['patat'] = {
        label = 'Patat',
        weight = 180,
        stack = true,
        close = true,
        consume = 1,
        description = 'Portie patat.',
        client = { image = 'patat.png', status = { hunger = 180000 }, anim = 'eating', prop = 'burger' }
    },

    ['loaded_fries'] = {
        label = 'Loaded Fries',
        weight = 350,
        stack = true,
        close = true,
        consume = 1,
        description = 'Patat met toppings, kaas en saus.',
        client = { image = 'loaded_fries.png', status = { hunger = 330000 }, anim = 'eating', prop = 'burger' }
    },

    ['tosti'] = {
        label = 'Tosti',
        weight = 190,
        stack = true,
        close = true,
        consume = 1,
        description = 'Warme tosti.',
        client = { image = 'tosti.png', status = { hunger = 190000 }, anim = 'eating', prop = 'burger' }
    },

    ['milkshake'] = {
        label = 'Milkshake',
        weight = 350,
        stack = true,
        close = true,
        consume = 1,
        description = 'Zoete milkshake.',
        client = { image = 'milkshake.png', status = { thirst = 260000 }, anim = 'drinking', prop = 'drink' }
    },

    ['roti_kip'] = {
        label = 'Roti Kip',
        weight = 450,
        stack = true,
        close = true,
        consume = 1,
        description = 'Roti met kip en aardappel.',
        client = { image = 'roti_kip.png', status = { hunger = 400000 }, anim = 'eating', prop = 'burger' }
    },

    ['broodje_pom'] = {
        label = 'Broodje Pom',
        weight = 220,
        stack = true,
        close = true,
        consume = 1,
        description = 'Surinaams broodje pom.',
        client = { image = 'broodje_pom.png', status = { hunger = 240000 }, anim = 'eating', prop = 'burger' }
    },

    ['broodje_kerrie'] = {
        label = 'Broodje Kerrie Kip',
        weight = 220,
        stack = true,
        close = true,
        consume = 1,
        description = 'Broodje kerrie kip.',
        client = { image = 'broodje_kerrie.png', status = { hunger = 240000 }, anim = 'eating', prop = 'burger' }
    },

    ['bara'] = {
        label = 'Bara',
        weight = 180,
        stack = true,
        close = true,
        consume = 1,
        description = 'Surinaamse bara.',
        client = { image = 'bara.png', status = { hunger = 180000 }, anim = 'eating', prop = 'burger' }
    },

    ['saoto_soep'] = {
        label = 'Saoto Soep',
        weight = 400,
        stack = true,
        close = true,
        consume = 1,
        description = 'Warme saoto soep.',
        client = { image = 'saoto_soep.png', status = { hunger = 300000 }, anim = 'eating', prop = 'burger' }
    },

    ['dawet'] = {
        label = 'Dawet',
        weight = 300,
        stack = true,
        close = true,
        consume = 1,
        description = 'Zoete Surinaamse drank.',
        client = { image = 'dawet.png', status = { thirst = 260000 }, anim = 'drinking', prop = 'drink' }
    },

    ['koffie'] = {
        label = 'Koffie',
        weight = 200,
        stack = true,
        close = true,
        consume = 1,
        description = 'Verse koffie.',
        client = { image = 'koffie.png', status = { thirst = 140000 }, anim = 'drinking', prop = 'drink' }
    },

    ['thee'] = {
        label = 'Thee',
        weight = 200,
        stack = true,
        close = true,
        consume = 1,
        description = 'Warme thee.',
        client = { image = 'thee.png', status = { thirst = 140000 }, anim = 'drinking', prop = 'drink' }
    },

    ['bitterballen'] = {
        label = 'Bitterballen',
        weight = 220,
        stack = true,
        close = true,
        consume = 1,
        description = 'Portie bitterballen.',
        client = { image = 'bitterballen.png', status = { hunger = 190000 }, anim = 'eating', prop = 'burger' }
    },

    ['chips'] = {
        label = 'Chips',
        weight = 120,
        stack = true,
        close = true,
        consume = 1,
        description = 'Zakje chips.',
        client = { image = 'chips.png', status = { hunger = 120000 }, anim = 'eating', prop = 'burger' }
    },

    ['nachos'] = {
        label = 'Nachos',
        weight = 260,
        stack = true,
        close = true,
        consume = 1,
        description = 'Nachos met kaas.',
        client = { image = 'nachos.png', status = { hunger = 240000 }, anim = 'eating', prop = 'burger' }
    },

    ['borrelplank'] = {
        label = 'Borrelplank',
        weight = 650,
        stack = true,
        close = true,
        consume = 1,
        description = 'Borrelplank met snacks, kaas en brood.',
        client = { image = 'borrelplank.png', status = { hunger = 450000 }, anim = 'eating', prop = 'burger' }
    },

    -- ==========================================
    -- Restaurant ingrediënten / voorraad
    -- ==========================================
    ['brood'] = { label = 'Brood', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['doner'] = { label = 'Doner', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['sla'] = { label = 'Sla', weight = 50, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['saus'] = { label = 'Saus', weight = 50, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['kip'] = { label = 'Kip', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['friet'] = { label = 'Friet', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['kaas'] = { label = 'Kaas', weight = 80, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['deeg'] = { label = 'Deeg', weight = 120, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['vleesmix'] = { label = 'Vleesmix', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['saus_tomaat'] = { label = 'Tomatensaus', weight = 80, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['burger'] = { label = 'Burger Patty', weight = 120, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['bacon'] = { label = 'Bacon', weight = 80, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['melk'] = { label = 'Melk', weight = 250, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['suiker'] = { label = 'Suiker', weight = 50, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['roti'] = { label = 'Roti Plaat', weight = 120, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['aardappel'] = { label = 'Aardappel', weight = 90, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['pom'] = { label = 'Pom', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['kerrie'] = { label = 'Kerrie', weight = 40, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['bara_deeg'] = { label = 'Bara Deeg', weight = 120, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['soep'] = { label = 'Soepbasis', weight = 200, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['siroop'] = { label = 'Siroop', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['koffiebonen'] = { label = 'Koffiebonen', weight = 60, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['theezakje'] = { label = 'Theezakje', weight = 10, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['bitterbal_mix'] = { label = 'Bitterbal Mix', weight = 120, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['chips_zak'] = { label = 'Chips Zak', weight = 100, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['nachos_chips'] = { label = 'Nachos Chips', weight = 120, stack = true, close = false, description = 'Ingrediënt voor horeca.' },
    ['snacks'] = { label = 'Snacks', weight = 140, stack = true, close = false, description = 'Ingrediënt voor horeca.' },

    -- ==========================================
    -- Control Center / Fanta rewards
    -- ==========================================
    ['fanta_giftbox'] = {
        label = 'Fanta Giftbox',
        weight = 250,
        stack = true,
        close = true,
        description = 'Cadeaubox uitgegeven via het Delfzijl RP Control Center.',
        client = { image = 'fanta_giftbox.png' }
    },

    ['drp_voucher'] = {
        label = 'Delfzijl RP Voucher',
        weight = 20,
        stack = true,
        close = true,
        description = 'Voucher voor events, acties of staff-beloningen.',
        client = { image = 'drp_voucher.png' }
    }
}
