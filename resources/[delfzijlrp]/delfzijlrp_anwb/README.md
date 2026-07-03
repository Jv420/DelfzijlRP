# Delfzijl RP ANWB

ANWB/garage uitbreiding voor Delfzijl RP bovenop Dispatch, RDW en voertuigsysteem.

## Features v0.1

- `/anwb`
- Mechanic job-check
- Dienststatus aan/uit
- ANWB servicepunt blip
- ANWB opslag via ox_inventory stash
- Voertuigdiagnose
- Voertuig repareren
- Voertuig schoonmaken
- APK vernieuwen
- Service afrekenen bij klant
- ANWB dispatch melding
- Reparatie/APK logs in database

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_anwb/sql/anwb.sql
```

2. Voeg toe aan `server.cfg` na Dispatch/RDW:

```cfg
ensure delfzijlrp_anwb
```

## Command

```text
/anwb
```

## Vereiste job

Standaard:

```text
mechanic
```

Aanpassen kan in `config.lua`.

## ox_inventory items

Zorg dat deze items bestaan:

```lua
['repairkit'] = { label = 'Reparatiekit', weight = 1000, stack = true, close = true },
['cleaningkit'] = { label = 'Schoonmaakset', weight = 500, stack = true, close = true },
['towrope'] = { label = 'Sleepkabel', weight = 1500, stack = false, close = true }
```

## Volgende uitbreidingen

- Echte sleepwagen attach/detach
- Flatbed transport
- ANWB tablet
- Reparatiehistorie in MDT
- Facturen koppelen aan business/banking
- Banden/olie/accu onderhoud
- Pechhulp abonnementen
