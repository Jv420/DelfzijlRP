# Delfzijl RP Dispatch

Meldkamersysteem voor 112, ambulance, ANWB en taxi.

## Features v0.1

- `/112` voor burgers
- `/meldkamer` voor hulpdiensten/bedrijven
- `/panic` voor paniekknop
- Politie, ambulance, ANWB en taxi meldingen
- Meldingen opslaan in database
- Meldingen aannemen
- Meldingen afsluiten
- Waypoint naar melding
- Service-notificaties

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_dispatch/sql/dispatch.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_dispatch
```

## Commands

```text
/112
/meldkamer
/panic
```

## Toegang

Standaard toegang tot `/meldkamer`:

- police
- ambulance
- mechanic
- taxi

Aanpassen kan in `config.lua`.

## Volgende uitbreidingen

- Telefoon-app integratie
- MDT integratie
- Live GPS voor hulpdiensten
- Prioriteit/categorieën
- Automatische meldingen uit crime scripts
- 112-centralist job
