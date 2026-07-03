# Delfzijl RP Fire Rescue

Brandweer- en technische hulpverlening resource voor Delfzijl RP.

## Features v0.1

- `/brandweer`
- Brandweer job-check
- Dienststatus aan/uit
- Brandweerkazerne met blip
- Brandweer garage
- Brandweer opslag via ox_inventory stash
- Brandweerwagen spawn
- Incidenten:
  - Voertuigbrand
  - Industrieel alarm
  - Technische hulpverlening
- Dispatch-koppeling
- Incident afronden met progress
- Bank payout
- Statistieken
- SQL logs

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_fire_rescue/sql/fire_rescue.sql
```

2. Voeg toe aan `server.cfg` na Dispatch:

```cfg
ensure delfzijlrp_fire_rescue
```

## Command

```text
/brandweer
```

## Vereiste job

Standaard:

```text
fire
```

Aanpassen kan in `config.lua`.

## ox_inventory items

```lua
['fire_extinguisher'] = { label = 'Brandblusser', weight = 1500, stack = false, close = true },
['fire_hose'] = { label = 'Brandslang', weight = 2500, stack = false, close = true },
['firstaid'] = { label = 'EHBO set', weight = 500, stack = true, close = true }
```

## Volgende uitbreidingen

- Hydranten systeem
- Echte brandobjecten/flames
- Slangen aansluiten
- Hoogwerker gameplay
- Gaslek/chemiepark calamiteiten
- Havenbrand scenario's
- Brandveiligheidsrapporten voor bedrijven
- Brandweer telefoon-app
