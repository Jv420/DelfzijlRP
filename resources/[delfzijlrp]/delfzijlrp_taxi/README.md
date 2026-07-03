# Delfzijl RP Taxi

Taxi-uitbreiding voor Delfzijl RP met ritten, taximeter en dispatch-koppeling.

## Features v0.1

- `/taxi`
- Taxi job-check
- Dienststatus aan/uit
- Taxi centrale blip
- Taxi garage
- Taxi en shuttlebus spawn
- Taximeter
- Klant afrekenen
- NPC-ritten
- Rittenlogboek in database
- Statistieken per chauffeur
- Dispatch shortcut

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_taxi/sql/taxi.sql
```

2. Voeg toe aan `server.cfg` na Dispatch:

```cfg
ensure delfzijlrp_taxi
```

## Command

```text
/taxi
```

## Vereiste job

Standaard:

```text
taxi
```

Aanpassen kan in `config.lua`.

## Volgende uitbreidingen

- Telefoon taxi-app
- Taxi dispatch claimen
- Bedrijfsrekening koppeling
- Chauffeur ratings
- Dynamische prijzen
- Routebonus
- Taxi abonnementen
