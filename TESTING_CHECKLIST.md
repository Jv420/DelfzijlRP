# Delfzijl RP - Test checklist

## 1. Eerst SQL importeren

Importeer alle SQL-bestanden uit de gebruikte resources voordat je de server start.

Belangrijkste nieuwe tabellen komen uit:

- `delfzijlrp_identity`
- `delfzijlrp_banking2`
- `delfzijlrp_dispatch`
- `delfzijlrp_vehicles`
- `delfzijlrp_garage`
- `delfzijlrp_anwb`
- `delfzijlrp_taxi`
- `delfzijlrp_city`
- `delfzijlrp_mdt_v2`
- `delfzijlrp_court`
- `delfzijlrp_prison`
- `delfzijlrp_fire_rescue`
- `delfzijlrp_business_v2`
- `delfzijlrp_groups`
- `delfzijlrp_housing_v2`
- `delfzijlrp_marketplace`
- `delfzijlrp_port`
- `delfzijlrp_public_transport`
- `delfzijlrp_cityhub`
- `delfzijlrp_phone_nui`

## 2. ox_inventory items controleren

Voeg minimaal deze items toe aan `ox_inventory/data/items.lua`:

```lua
['phone'] = { label = 'Telefoon', weight = 250, stack = false, close = true },
['bus_ticket'] = { label = 'Busticket', weight = 10, stack = true, close = true },
['repairkit'] = { label = 'Reparatiekit', weight = 1000, stack = true, close = true },
['cleaningkit'] = { label = 'Schoonmaakset', weight = 500, stack = true, close = true },
['towrope'] = { label = 'Sleepkabel', weight = 1500, stack = false, close = true },
['fire_extinguisher'] = { label = 'Brandblusser', weight = 1500, stack = false, close = true },
['fire_hose'] = { label = 'Brandslang', weight = 2500, stack = false, close = true },
['firstaid'] = { label = 'EHBO set', weight = 500, stack = true, close = true },
['port_food_crate'] = { label = 'Havenkrat Voedsel', weight = 2500, stack = true, close = true },
['port_medical_crate'] = { label = 'Havenkrat Medisch', weight = 2200, stack = true, close = true },
['port_electronics_crate'] = { label = 'Havenkrat Elektronica', weight = 3000, stack = true, close = true },
['port_fuel_manifest'] = { label = 'Brandstof Manifest', weight = 100, stack = true, close = true },
['port_construction_crate'] = { label = 'Havenkrat Bouwmateriaal', weight = 3500, stack = true, close = true }
```

## 3. Jobs controleren

Zorg dat deze jobs bestaan in ESX:

- `police`
- `ambulance`
- `mechanic`
- `taxi`
- `fire`
- `judge`
- `lawyer`
- `customs`
- `government`
- `busdriver`
- `trucker`

## 4. Testvolgorde in-game

Test eerst basislaag:

1. `/gemeente`
2. `/bank`
3. `/phone`
4. `/garage`
5. `/mdt2`

Daarna jobs:

1. `/taxi`
2. `/anwb`
3. `/brandweer`
4. `/busdienst`
5. `/haven`

Daarna systemen:

1. `/kadaster`
2. `/huis`
3. `/bedrijf2`
4. `/groep`
5. `/marktplaats`
6. `/rechtbank`
7. `/gevangenis`

## 5. Belangrijk server.cfg punt

`es_extended` moet vóór `ox_inventory` starten.

Goede volgorde:

```cfg
ensure oxmysql
ensure ox_lib
ensure es_extended
ensure ox_target
ensure ox_inventory
ensure ox_doorlock
```

## 6. Eerste testadvies

Start niet meteen met 30 spelers. Test eerst lokaal of met 1-2 spelers en kijk in console naar:

- missing dependency
- unknown command
- SQL table does not exist
- attempt to index nil value
- export not found
