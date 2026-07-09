return {
	-- =========================
	-- FOOD / DRINKS
	-- =========================
	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'Je at een burger'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'Je dronk water'
		}
	},

	['cola'] = {
		label = 'Cola',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ecola_can`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'Je dronk cola'
		}
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'Je dronk sprunk'
		}
	},

	['coffee'] = {
		label = 'Koffie',
		weight = 250,
		client = {
			status = { thirst = 120000, stress = -50000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `p_amb_coffeecup_01`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			notification = 'Je dronk koffie'
		}
	},

	['sandwich'] = {
		label = 'Sandwich',
		weight = 220,
		client = { status = { hunger = 180000 }, anim = 'eating', prop = 'sandwich', usetime = 2500 }
	},

	['hotdog'] = {
		label = 'Hotdog',
		weight = 220,
		client = { status = { hunger = 180000 }, anim = 'eating', usetime = 2500 }
	},

	['donut'] = {
		label = 'Donut',
		weight = 120,
		client = { status = { hunger = 100000 }, anim = 'eating', usetime = 2000 }
	},

	['chocolate'] = {
		label = 'Chocolade',
		weight = 100,
		client = { status = { hunger = 80000 }, anim = 'eating', usetime = 2000 }
	},

	['bread'] = {
		label = 'Brood',
		weight = 100,
		stack = true,
		close = true,
		client = { status = { hunger = 120000 }, anim = 'eating', usetime = 2000 }
	},

	-- =========================
	-- ALCOHOL / SMOKING RP
	-- =========================
	['beer'] = { label = 'Bier', weight = 500, client = { status = { thirst = 100000, stress = -30000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, prop = { model = `prop_amb_beer_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) }, usetime = 2500 } },
	['wine'] = { label = 'Wijn', weight = 500, client = { status = { thirst = 90000, stress = -35000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, usetime = 2500 } },
	['whiskey'] = { label = 'Whiskey', weight = 500, client = { status = { thirst = 80000, stress = -50000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, usetime = 2500 } },
	['vodka'] = { label = 'Vodka', weight = 500, client = { status = { thirst = 80000, stress = -50000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, usetime = 2500 } },
	['tequila'] = { label = 'Tequila', weight = 500, client = { status = { thirst = 80000, stress = -50000 }, anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' }, usetime = 2500 } },
	['lighter'] = { label = 'Aansteker', weight = 50, stack = true, close = true },
	['cigarette'] = { label = 'Sigaret', weight = 10, stack = true, close = true },
	['cigar'] = { label = 'Sigaar', weight = 25, stack = true, close = true },
	['vape'] = { label = 'Vape', weight = 150, stack = false, close = true },

	-- =========================
	-- GENERAL RP
	-- =========================
	['phone'] = { label = 'Telefoon', weight = 190, stack = false, consume = 0 },
	['radio'] = { label = 'Radio', weight = 1000, stack = false, allowArmed = true },
	['parachute'] = { label = 'Parachute', weight = 8000, stack = false, client = { anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' }, usetime = 1500 } },
	['binoculars'] = { label = 'Verrekijker', weight = 800, stack = false, close = true },
	['id_card'] = { label = 'ID Kaart', weight = 10, stack = false, close = true },
	['driver_license'] = { label = 'Rijbewijs', weight = 10, stack = false, close = true },
	['weapon_license'] = { label = 'Wapenvergunning', weight = 10, stack = false, close = true },
	['notepad'] = { label = 'Notitieboekje', weight = 100, stack = true, close = true },
	['pen'] = { label = 'Pen', weight = 20, stack = true, close = true },
	['backpack'] = { label = 'Rugzak', weight = 1000, stack = false, close = true },
	['umbrella'] = { label = 'Paraplu', weight = 700, stack = false, close = true },

	-- =========================
	-- TOOLS / GARAGE
	-- =========================
	['lockpick'] = { label = 'Lockpick', weight = 160, stack = true, close = true },
	['advancedlockpick'] = { label = 'Advanced Lockpick', weight = 250, stack = true, close = true },
	['repairkit'] = { label = 'Repair Kit', weight = 1000, stack = true, close = true },
	['fixkit'] = { label = 'Repair Kit', weight = 1000, stack = true, close = true },
	['cleaningkit'] = { label = 'Cleaning Kit', weight = 500, stack = true, close = true },
	['drill'] = { label = 'Drill', weight = 2500, stack = false, close = true },
	['rope'] = { label = 'Touw', weight = 500, stack = true, close = true },
	['toolbox'] = { label = 'Gereedschapskist', weight = 2500, stack = false, close = true },
	['welding_torch'] = { label = 'Lasapparaat', weight = 3500, stack = false, close = true },
	['tirekit'] = { label = 'Bandenkit', weight = 1200, stack = true, close = true },
	['engine_oil'] = { label = 'Motorolie', weight = 800, stack = true, close = true },
	['car_battery'] = { label = 'Auto Accu', weight = 5000, stack = true, close = true },
	['spark_plug'] = { label = 'Bougie', weight = 200, stack = true, close = true },

	-- =========================
	-- POLICE
	-- =========================
	['handcuffs'] = { label = 'Handboeien', weight = 500, stack = false, close = true },
	['zipties'] = { label = 'Tie-wraps', weight = 100, stack = true, close = true },
	['bodycam'] = { label = 'Bodycam', weight = 300, stack = false, close = true },
	['dashcam'] = { label = 'Dashcam', weight = 300, stack = false, close = true },
	['breathalyzer'] = { label = 'Alcoholtester', weight = 300, stack = false, close = true },
	['evidence_bag'] = { label = 'Bewijszakje', weight = 20, stack = true, close = true },
	['spikestrip'] = { label = 'Spijkermat', weight = 3000, stack = false, close = true },
	['police_badge'] = { label = 'Politie Badge', weight = 100, stack = false, close = true },

	-- =========================
	-- MEDICAL
	-- =========================
	['bandage'] = { label = 'Bandage', weight = 115, client = { anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 }, disable = { move = true, car = true, combat = true }, usetime = 2500 } },
	['medikit'] = { label = 'Medikit', weight = 500, stack = true, close = true },
	['painkillers'] = { label = 'Pijnstillers', weight = 100, stack = true, close = true },
	['firstaid'] = { label = 'EHBO Kit', weight = 800, stack = true, close = true },
	['defib'] = { label = 'Defibrillator', weight = 3000, stack = false, close = true },
	['stretcher'] = { label = 'Brancard', weight = 5000, stack = false, close = true },
	['medical_bag'] = { label = 'Medische Tas', weight = 2500, stack = false, close = true },
	['morphine'] = { label = 'Morfine RP', weight = 100, stack = true, close = true },
	['adrenaline'] = { label = 'Adrenaline RP', weight = 100, stack = true, close = true },

	-- =========================
	-- WEAPON ATTACHMENTS / AMMO ITEMS
	-- =========================
	['at_suppressor_light'] = { label = 'Suppressor', weight = 500, stack = true, close = true },
	['at_clip_extended_pistol'] = { label = 'Extended Pistol Clip', weight = 300, stack = true, close = true },
	['at_flashlight'] = { label = 'Weapon Flashlight', weight = 250, stack = true, close = true },
	['at_scope_small'] = { label = 'Small Scope', weight = 400, stack = true, close = true },
	['weapon_cleaningkit'] = { label = 'Wapen Schoonmaakset', weight = 500, stack = true, close = true },

	-- =========================
	-- FICTIONAL CRIME / DRUG RP ITEMS
	-- Geen echte recepten, alleen RP-props.
	-- =========================
	['weed_leaf'] = { label = 'Wietblad', weight = 10, stack = true, close = true },
	['weed_bag'] = { label = 'Zakje Wiet', weight = 20, stack = true, close = true },
	['coca_leaf'] = { label = 'Cocablad', weight = 10, stack = true, close = true },
	['coke_bag'] = { label = 'Zakje Coke', weight = 20, stack = true, close = true },
	['bakingsoda'] = { label = 'Baking Soda RP', weight = 100, stack = true, close = true },
	['empty_baggy'] = { label = 'Leeg Zakje', weight = 5, stack = true, close = true },
	['ghb_bottle'] = { label = 'Fictief Flesje', weight = 120, stack = true, close = true },
	['empty_bottle'] = { label = 'Leeg Flesje', weight = 20, stack = true, close = true },
	['chemical_powder'] = { label = 'Fictief Chemisch Poeder', weight = 150, stack = true, close = true },
	['lab_card'] = { label = 'Lab Pas', weight = 50, stack = false, close = true },
	['burner_phone'] = { label = 'Prepaid Telefoon', weight = 190, stack = false, close = true },
	['fake_plate'] = { label = 'Valse Kentekenplaat', weight = 500, stack = true, close = true },
	['marked_bills'] = { label = 'Gemarkeerd Geld', weight = 50, stack = true, close = true },
	['money_roll'] = { label = 'Geldrol', weight = 100, stack = true, close = true },
	['money_bag'] = { label = 'Geldtas', weight = 1000, stack = false, close = true },
	['black_usb'] = { label = 'Zwarte USB Stick', weight = 50, stack = true, close = true },
	['hacking_laptop'] = { label = 'Hacking Laptop RP', weight = 2500, stack = false, close = true },

	-- =========================
	-- BURGLARY / CAR THEFT RP TOOLS
	-- =========================
	['crowbar'] = { label = 'Breekijzer', weight = 1200, stack = false, close = true },
	['glass_cutter'] = { label = 'Glassnijder', weight = 700, stack = false, close = true },
	['screwdriver'] = { label = 'Schroevendraaier', weight = 300, stack = true, close = true },
	['pliers'] = { label = 'Tang', weight = 350, stack = true, close = true },
	['thermite'] = { label = 'Thermite RP', weight = 750, stack = true, close = true },
	['keycard_basic'] = { label = 'Basic Keycard', weight = 50, stack = true, close = true },
	['keycard_advanced'] = { label = 'Advanced Keycard', weight = 50, stack = true, close = true },
	['car_decoder'] = { label = 'Auto Decoder RP', weight = 900, stack = false, close = true },
	['signal_jammer'] = { label = 'Signal Jammer RP', weight = 1200, stack = false, close = true },
	['tracker_remover'] = { label = 'Tracker Verwijderaar RP', weight = 1000, stack = false, close = true },
	['vin_scratch_tool'] = { label = 'VIN Tool RP', weight = 700, stack = false, close = true },
	['car_key_blank'] = { label = 'Lege Autosleutel', weight = 80, stack = true, close = true },
	['stolen_radio'] = { label = 'Gestolen Radio', weight = 1000, stack = true, close = true },
	['stolen_gps'] = { label = 'Gestolen GPS', weight = 600, stack = true, close = true },
	['stolen_catalyst'] = { label = 'Katalysator', weight = 2200, stack = true, close = true },

	-- =========================
	-- VALUABLES / LOOT
	-- =========================
	['gold_watch'] = { label = 'Gouden Horloge', weight = 150, stack = true, close = true },
	['gold_chain'] = { label = 'Gouden Ketting', weight = 150, stack = true, close = true },
	['diamond_ring'] = { label = 'Diamanten Ring', weight = 100, stack = true, close = true },
	['rolex'] = { label = 'Rolex', weight = 150, stack = true, close = true },
	['laptop'] = { label = 'Laptop', weight = 2500, stack = false, close = true },
	['tablet'] = { label = 'Tablet', weight = 800, stack = false, close = true },
	['camera'] = { label = 'Camera', weight = 700, stack = false, close = true },
	['gaming_console'] = { label = 'Game Console', weight = 1800, stack = true, close = true },
	['jewels'] = { label = 'Juwelen', weight = 500, stack = true, close = true },

	-- =========================
	-- MATERIALS / JOB ITEMS
	-- =========================
	['copper'] = { label = 'Copper', weight = 100, stack = true, close = true },
	['iron'] = { label = 'Iron', weight = 100, stack = true, close = true },
	['gold'] = { label = 'Gold', weight = 100, stack = true, close = true },
	['diamond'] = { label = 'Diamond', weight = 100, stack = true, close = true },
	['wood'] = { label = 'Wood', weight = 100, stack = true, close = true },
	['stone'] = { label = 'Stone', weight = 100, stack = true, close = true },
	['washed_stone'] = { label = 'Washed Stone', weight = 100, stack = true, close = true },
	['fabric'] = { label = 'Fabric', weight = 100, stack = true, close = true },
	['wool'] = { label = 'Wool', weight = 100, stack = true, close = true },
	['fish'] = { label = 'Fish', weight = 100, stack = true, close = true },

	["carjack"] = {
		label = "Krik",
		weight = 2500,
		stack = true,
		close = true,
	},

	["glass"] = {
		label = "Glas",
		weight = 50,
		stack = true,
		close = true,
	},

	["pizza_slice"] = {
		label = "Pizzapunt",
		weight = 180,
		stack = true,
		close = true,
	},

	["plastic"] = {
		label = "Plastic",
		weight = 50,
		stack = true,
		close = true,
	},

	["tyrekit"] = {
		label = "Bandenkit",
		weight = 1200,
		stack = true,
		close = true,
	},

	["apple"] = {
		label = "Appel",
		weight = 80,
		stack = true,
		close = true,
	},

	["icepack"] = {
		label = "Koelpack",
		weight = 200,
		stack = true,
		close = true,
	},

	["salmon"] = {
		label = "Zalm",
		weight = 200,
		stack = true,
		close = true,
	},

	["bait"] = {
		label = "Aas",
		weight = 10,
		stack = true,
		close = true,
	},

	["wallet"] = {
		label = "Portemonnee",
		weight = 100,
		stack = true,
		close = true,
	},

	["banana"] = {
		label = "Banaan",
		weight = 100,
		stack = true,
		close = true,
	},

	["usb_stick"] = {
		label = "USB Stick",
		weight = 20,
		stack = true,
		close = true,
	},

	["bankcard"] = {
		label = "Bankpas",
		weight = 20,
		stack = true,
		close = true,
	},

	["lab_keycard"] = {
		label = "Lab Keycard",
		weight = 20,
		stack = true,
		close = true,
	},

	["tuna"] = {
		label = "Tonijn",
		weight = 300,
		stack = true,
		close = true,
	},

	["fishingrod"] = {
		label = "Hengel",
		weight = 1000,
		stack = true,
		close = true,
	},

	["steel"] = {
		label = "Staal",
		weight = 100,
		stack = true,
		close = true,
	},

	["carbattery"] = {
		label = "Auto Accu",
		weight = 5000,
		stack = true,
		close = true,
	},

	["spike_strip"] = {
		label = "Spijkermat",
		weight = 1500,
		stack = true,
		close = true,
	},

	["sparkplug"] = {
		label = "Bougie",
		weight = 80,
		stack = true,
		close = true,
	},

	["fingerprint_kit"] = {
		label = "Vingerafdruk Kit",
		weight = 500,
		stack = true,
		close = true,
	},

	["rubber"] = {
		label = "Rubber",
		weight = 50,
		stack = true,
		close = true,
	},

	["syringe"] = {
		label = "Spuit",
		weight = 20,
		stack = true,
		close = true,
	},

	["nos"] = {
		label = "NOS Fles",
		weight = 3000,
		stack = true,
		close = true,
	},

	["taco"] = {
		label = "Taco",
		weight = 180,
		stack = true,
		close = true,
	},

	["fries"] = {
		label = "Friet",
		weight = 150,
		stack = true,
		close = true,
	},

	["goldchain"] = {
		label = "Gouden Ketting",
		weight = 150,
		stack = true,
		close = true,
	},
	['lockpick'] = {
    label = 'Lockpick',
    weight = 80,
    stack = true,
    close = true,
    description = 'Een eenvoudige lockpick voor RP-situaties.'
},

['advancedlockpick'] = {
    label = 'Geavanceerde Lockpick',
    weight = 120,
    stack = true,
    close = true,
    description = 'Sterkere lockpick voor moeilijkere RP-situaties.'
},

['drill'] = {
    label = 'Boormachine',
    weight = 2500,
    stack = false,
    close = true,
    description = 'Gereedschap voor speciale RP-scenario’s.'
},

['thermite'] = {
    label = 'Thermiet',
    weight = 500,
    stack = true,
    close = true,
    description = 'Illegaal RP-item. Alleen gebruiken binnen serverregels.'
},

['black_phone'] = {
    label = 'Zwarte Telefoon',
    weight = 250,
    stack = false,
    close = true,
    description = 'Telefoon voor criminele RP-contacten.'
},

['toolbox'] = {
    label = 'Gereedschapskist',
    weight = 2000,
    stack = false,
    close = true,
    description = 'Handige kist met gereedschap.'
},

['repairkit'] = {
    label = 'Reparatiekit',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Voor simpele voertuigreparaties.'
},

['advancedrepairkit'] = {
    label = 'Uitgebreide Reparatiekit',
    weight = 1800,
    stack = true,
    close = true,
    description = 'Voor betere voertuigreparaties.'
},

['cleaningkit'] = {
    label = 'Schoonmaakset',
    weight = 500,
    stack = true,
    close = true,
    description = 'Voor het schoonmaken van voertuigen.'
},

['carjack'] = {
    label = 'Autokrik',
    weight = 3000,
    stack = false,
    close = true,
    description = 'ANWB-gereedschap voor voertuigen.'
},

['simcard'] = {
    label = 'Simkaart',
    weight = 10,
    stack = true,
    close = true,
    description = 'Simkaart voor telefoonsystemen.'
},

	-- =========================
	-- DELFZIJLRP MERGE: GEMEENTE DOCUMENTEN
	-- =========================
	['idkaart'] = {
		label = 'ID-kaart',
		weight = 50,
		stack = false,
		close = true,
		description = 'ID-kaart uitgegeven door Gemeente Delfzijl.',
	},
	['paspoort'] = {
		label = 'Paspoort',
		weight = 50,
		stack = false,
		close = true,
		description = 'Paspoort uitgegeven door Gemeente Delfzijl.',
	},
	['rijbewijs'] = {
		label = 'Rijbewijs B',
		weight = 50,
		stack = false,
		close = true,
		description = 'Rijbewijs B uitgegeven door Gemeente Delfzijl.',
	},
	['motorrijbewijs'] = {
		label = 'Motorrijbewijs A',
		weight = 50,
		stack = false,
		close = true,
		description = 'Motorrijbewijs A uitgegeven door Gemeente Delfzijl.',
	},
	['vrachtwagenrijbewijs'] = {
		label = 'Vrachtwagenrijbewijs C',
		weight = 50,
		stack = false,
		close = true,
		description = 'Vrachtwagenrijbewijs C uitgegeven door Gemeente Delfzijl.',
	},
	['busrijbewijs'] = {
		label = 'Busrijbewijs D',
		weight = 50,
		stack = false,
		close = true,
		description = 'Busrijbewijs D uitgegeven door Gemeente Delfzijl.',
	},
	['vaarbewijs'] = {
		label = 'Vaarbewijs',
		weight = 50,
		stack = false,
		close = true,
		description = 'Vaarbewijs uitgegeven door Gemeente Delfzijl.',
	},
	['visvergunning'] = {
		label = 'Visvergunning',
		weight = 50,
		stack = false,
		close = true,
		description = 'Visvergunning uitgegeven door Gemeente Delfzijl.',
	},
	['werkvergunning'] = {
		label = 'Werkvergunning',
		weight = 50,
		stack = false,
		close = true,
		description = 'Werkvergunning uitgegeven door Gemeente Delfzijl.',
	},
	['bouwvergunning'] = {
		label = 'Bouwvergunning',
		weight = 50,
		stack = false,
		close = true,
		description = 'Bouwvergunning uitgegeven door Gemeente Delfzijl.',
	},
	['marktvergunning'] = {
		label = 'Marktvergunning',
		weight = 50,
		stack = false,
		close = true,
		description = 'Marktvergunning uitgegeven door Gemeente Delfzijl.',
	},
	['uittreksel_brp'] = {
		label = 'Uittreksel BRP',
		weight = 50,
		stack = false,
		close = true,
		description = 'Uittreksel BRP uitgegeven door Gemeente Delfzijl.',
	},
	['geboorteakte'] = {
		label = 'Geboorteakte',
		weight = 50,
		stack = false,
		close = true,
		description = 'Geboorteakte uitgegeven door Gemeente Delfzijl.',
	},
	['verhuisverklaring'] = {
		label = 'Verhuisverklaring',
		weight = 50,
		stack = false,
		close = true,
		description = 'Verhuisverklaring uitgegeven door Gemeente Delfzijl.',
	},

	-- =========================
	-- DELFZIJLRP MERGE: RESTAURANT GERECHTEN
	-- =========================
	['broodje_doner'] = {
		label = 'Broodje Doner',
		weight = 220,
		stack = true,
		close = true,
		consume = 1,
		description = 'Broodje Doner van Delfzijl RP horeca.',
		client = { status = { hunger = 220000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['broodje_kip'] = {
		label = 'Broodje Kip',
		weight = 220,
		stack = true,
		close = true,
		consume = 1,
		description = 'Broodje Kip van Delfzijl RP horeca.',
		client = { status = { hunger = 220000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['kapsalon_klein'] = {
		label = 'Kleine Kapsalon',
		weight = 350,
		stack = true,
		close = true,
		consume = 1,
		description = 'Kleine Kapsalon van Delfzijl RP horeca.',
		client = { status = { hunger = 300000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['kapsalon_groot'] = {
		label = 'Grote Kapsalon',
		weight = 550,
		stack = true,
		close = true,
		consume = 1,
		description = 'Grote Kapsalon van Delfzijl RP horeca.',
		client = { status = { hunger = 450000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['lahmacun'] = {
		label = 'Lahmacun',
		weight = 240,
		stack = true,
		close = true,
		consume = 1,
		description = 'Lahmacun van Delfzijl RP horeca.',
		client = { status = { hunger = 260000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['pizza_doner'] = {
		label = 'Pizza Doner',
		weight = 600,
		stack = true,
		close = true,
		consume = 1,
		description = 'Pizza Doner van Delfzijl RP horeca.',
		client = { status = { hunger = 430000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['pizza_margherita'] = {
		label = 'Pizza Margherita',
		weight = 520,
		stack = true,
		close = true,
		consume = 1,
		description = 'Pizza Margherita van Delfzijl RP horeca.',
		client = { status = { hunger = 380000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['ayran'] = {
		label = 'Ayran',
		weight = 250,
		stack = true,
		close = true,
		consume = 1,
		description = 'Ayran van Delfzijl RP horeca.',
		client = { status = { thirst = 250000 }, anim = 'drinking', prop = 'drink', usetime = 2500 },
	},
	['hamburger'] = {
		label = 'Hamburger',
		weight = 250,
		stack = true,
		close = true,
		consume = 1,
		description = 'Hamburger van Delfzijl RP horeca.',
		client = { status = { hunger = 260000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['cheeseburger'] = {
		label = 'Cheeseburger',
		weight = 270,
		stack = true,
		close = true,
		consume = 1,
		description = 'Cheeseburger van Delfzijl RP horeca.',
		client = { status = { hunger = 290000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['baconburger'] = {
		label = 'Baconburger',
		weight = 300,
		stack = true,
		close = true,
		consume = 1,
		description = 'Baconburger van Delfzijl RP horeca.',
		client = { status = { hunger = 330000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['patat'] = {
		label = 'Patat',
		weight = 180,
		stack = true,
		close = true,
		consume = 1,
		description = 'Patat van Delfzijl RP horeca.',
		client = { status = { hunger = 180000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['loaded_fries'] = {
		label = 'Loaded Fries',
		weight = 350,
		stack = true,
		close = true,
		consume = 1,
		description = 'Loaded Fries van Delfzijl RP horeca.',
		client = { status = { hunger = 330000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['tosti'] = {
		label = 'Tosti',
		weight = 190,
		stack = true,
		close = true,
		consume = 1,
		description = 'Tosti van Delfzijl RP horeca.',
		client = { status = { hunger = 190000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['milkshake'] = {
		label = 'Milkshake',
		weight = 350,
		stack = true,
		close = true,
		consume = 1,
		description = 'Milkshake van Delfzijl RP horeca.',
		client = { status = { thirst = 260000 }, anim = 'drinking', prop = 'drink', usetime = 2500 },
	},
	['roti_kip'] = {
		label = 'Roti Kip',
		weight = 450,
		stack = true,
		close = true,
		consume = 1,
		description = 'Roti Kip van Delfzijl RP horeca.',
		client = { status = { hunger = 400000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['broodje_pom'] = {
		label = 'Broodje Pom',
		weight = 220,
		stack = true,
		close = true,
		consume = 1,
		description = 'Broodje Pom van Delfzijl RP horeca.',
		client = { status = { hunger = 240000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['broodje_kerrie'] = {
		label = 'Broodje Kerrie Kip',
		weight = 220,
		stack = true,
		close = true,
		consume = 1,
		description = 'Broodje Kerrie Kip van Delfzijl RP horeca.',
		client = { status = { hunger = 240000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['bara'] = {
		label = 'Bara',
		weight = 180,
		stack = true,
		close = true,
		consume = 1,
		description = 'Bara van Delfzijl RP horeca.',
		client = { status = { hunger = 180000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['saoto_soep'] = {
		label = 'Saoto Soep',
		weight = 400,
		stack = true,
		close = true,
		consume = 1,
		description = 'Saoto Soep van Delfzijl RP horeca.',
		client = { status = { hunger = 300000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['dawet'] = {
		label = 'Dawet',
		weight = 300,
		stack = true,
		close = true,
		consume = 1,
		description = 'Dawet van Delfzijl RP horeca.',
		client = { status = { thirst = 260000 }, anim = 'drinking', prop = 'drink', usetime = 2500 },
	},
	['koffie'] = {
		label = 'Koffie',
		weight = 200,
		stack = true,
		close = true,
		consume = 1,
		description = 'Koffie van Delfzijl RP horeca.',
		client = { status = { thirst = 140000 }, anim = 'drinking', prop = 'drink', usetime = 2500 },
	},
	['thee'] = {
		label = 'Thee',
		weight = 200,
		stack = true,
		close = true,
		consume = 1,
		description = 'Thee van Delfzijl RP horeca.',
		client = { status = { thirst = 140000 }, anim = 'drinking', prop = 'drink', usetime = 2500 },
	},
	['bitterballen'] = {
		label = 'Bitterballen',
		weight = 220,
		stack = true,
		close = true,
		consume = 1,
		description = 'Bitterballen van Delfzijl RP horeca.',
		client = { status = { hunger = 190000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['chips'] = {
		label = 'Chips',
		weight = 120,
		stack = true,
		close = true,
		consume = 1,
		description = 'Chips van Delfzijl RP horeca.',
		client = { status = { hunger = 120000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['nachos'] = {
		label = 'Nachos',
		weight = 260,
		stack = true,
		close = true,
		consume = 1,
		description = 'Nachos van Delfzijl RP horeca.',
		client = { status = { hunger = 240000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},
	['borrelplank'] = {
		label = 'Borrelplank',
		weight = 650,
		stack = true,
		close = true,
		consume = 1,
		description = 'Borrelplank van Delfzijl RP horeca.',
		client = { status = { hunger = 450000 }, anim = 'eating', prop = 'burger', usetime = 2500 },
	},

	-- =========================
	-- DELFZIJLRP MERGE: RESTAURANT INGREDIËNTEN
	-- =========================
	['brood'] = {
		label = 'Brood',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['doner'] = {
		label = 'Doner',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['sla'] = {
		label = 'Sla',
		weight = 50,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['saus'] = {
		label = 'Saus',
		weight = 50,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['kip'] = {
		label = 'Kip',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['friet'] = {
		label = 'Friet',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['kaas'] = {
		label = 'Kaas',
		weight = 80,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['deeg'] = {
		label = 'Deeg',
		weight = 120,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['vleesmix'] = {
		label = 'Vleesmix',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['saus_tomaat'] = {
		label = 'Tomatensaus',
		weight = 80,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['bacon'] = {
		label = 'Bacon',
		weight = 80,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['melk'] = {
		label = 'Melk',
		weight = 250,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['suiker'] = {
		label = 'Suiker',
		weight = 50,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['roti'] = {
		label = 'Roti Plaat',
		weight = 120,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['aardappel'] = {
		label = 'Aardappel',
		weight = 90,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['pom'] = {
		label = 'Pom',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['kerrie'] = {
		label = 'Kerrie',
		weight = 40,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['bara_deeg'] = {
		label = 'Bara Deeg',
		weight = 120,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['soep'] = {
		label = 'Soepbasis',
		weight = 200,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['siroop'] = {
		label = 'Siroop',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['koffiebonen'] = {
		label = 'Koffiebonen',
		weight = 60,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['theezakje'] = {
		label = 'Theezakje',
		weight = 10,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['bitterbal_mix'] = {
		label = 'Bitterbal Mix',
		weight = 120,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['chips_zak'] = {
		label = 'Chips Zak',
		weight = 100,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['nachos_chips'] = {
		label = 'Nachos Chips',
		weight = 120,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},
	['snacks'] = {
		label = 'Snacks',
		weight = 140,
		stack = true,
		close = false,
		description = 'Ingrediënt voor Delfzijl RP horeca.',
	},

	-- =========================
	-- DELFZIJLRP MERGE: FANTA / CONTROL CENTER
	-- =========================
	['fanta_giftbox'] = {
		label = 'Fanta Giftbox',
		weight = 250,
		stack = true,
		close = true,
		description = 'Fanta Giftbox voor Fanta / Control Center acties.',
	},
	['drp_voucher'] = {
		label = 'Delfzijl RP Voucher',
		weight = 20,
		stack = true,
		close = true,
		description = 'Delfzijl RP Voucher voor Fanta / Control Center acties.',
	},
}
