# Delfzijl RP Public Transport

Qbuzz-stijl openbaar vervoer voor Delfzijl RP.

## Features v0.1

- `/bus`
- `/busdienst`
- Busdepot met ox_target
- Buschauffeur job: `busdriver`
- Bus spawn
- Bustickets kopen
- Enkele reis en dagkaart
- Buslijnen met haltes
- Route starten
- Haltes bedienen
- Chauffeur payout
- Rittenstatistieken
- SQL logs

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_public_transport/sql/public_transport.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_public_transport
```

3. Voeg item toe aan `ox_inventory/data/items.lua`:

```lua
['bus_ticket'] = { label = 'Busticket', weight = 10, stack = true, close = true }
```

## Commands

```text
/bus
/busdienst
```

## Volgende uitbreidingen

- OV-chipkaart
- Telefoon reisplanner
- Dynamische dienstregeling
- Treinlijnen
- Veerboot/jachthaven route
- Gemeentelijke subsidie via city treasury
