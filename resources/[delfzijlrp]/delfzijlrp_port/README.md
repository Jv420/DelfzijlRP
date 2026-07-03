# Delfzijl RP Port

Havenlogistiek voor Delfzijl RP, gebaseerd op Delfzijl/Eemshaven sfeer.

## Features v0.1

- `/haven`
- `/havenwerk`
- Havenkantoor
- Containerterminal
- Tankterminal
- Import/export opdrachten
- Lading ophalen
- Lading scannen
- Lading afleveren
- Kans op douanecontrole
- Dispatch melding bij verdachte lading
- Bank payout
- Havenstatistieken
- SQL logs

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_port/sql/port.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_port
```

3. Voeg items toe aan `ox_inventory/data/items.lua`:

```lua
['port_food_crate'] = { label = 'Havenkrat Voedsel', weight = 2500, stack = true, close = true },
['port_medical_crate'] = { label = 'Havenkrat Medisch', weight = 2200, stack = true, close = true },
['port_electronics_crate'] = { label = 'Havenkrat Elektronica', weight = 3000, stack = true, close = true },
['port_fuel_manifest'] = { label = 'Brandstof Manifest', weight = 100, stack = true, close = true },
['port_construction_crate'] = { label = 'Havenkrat Bouwmateriaal', weight = 3500, stack = true, close = true }
```

## Commands

```text
/haven
/havenwerk
```

## Gameplay flow

1. Start opdracht bij Havenkantoor.
2. Ga naar pickup punt.
3. Scan de lading.
4. Lever af bij dropoff.
5. Ontvang betaling op bank.

## Volgende uitbreidingen

- Douane job menu
- Containerkraan minigame
- Truck/Trailer vereiste
- Bedrijven bestellingen laten plaatsen
- Brandstof koppelen aan tankstations
- Havenpolitie
- Scheepsleveringen
- Eemshaven windpark/offshore opdrachten
