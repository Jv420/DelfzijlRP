# Delfzijl RP Jobs

Legale burgerbanen voor Delfzijl RP.

## Features v0.1

- `/werk`
- UWV-loket
- Vuilnisdienst
- PostNL bezorger
- Visser
- Houthakker
- Boer
- Mijnwerker
- Werkpunten via ox_target
- Goederen verdienen
- Goederen inleveren voor bankbetaling
- Werkstatistieken in database

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_jobs/sql/jobs.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_jobs
```

3. Voeg items toe aan `ox_inventory/data/items.lua`.

## ox_inventory items

```lua
['recyclable_material'] = {
    label = 'Recyclebaar materiaal',
    weight = 250,
    stack = true,
    close = true
},

['parcel'] = {
    label = 'Pakketje',
    weight = 500,
    stack = true,
    close = true
},

['fish'] = {
    label = 'Vis',
    weight = 600,
    stack = true,
    close = true
},

['wood'] = {
    label = 'Hout',
    weight = 700,
    stack = true,
    close = true
},

['vegetables'] = {
    label = 'Groenten',
    weight = 350,
    stack = true,
    close = true
},

['ore'] = {
    label = 'Erts',
    weight = 900,
    stack = true,
    close = true
}
```

## Volgende uitbreidingen

- Jobvoertuigen
- Routes met random punten
- Levels en bonussen
- Leaderboards
- Bedrijven koppelen aan jobs
- Phone werk-app
- Anti-farm cooldowns
