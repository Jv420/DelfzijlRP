# Delfzijl RP Ambulance

Ambulance/EMS uitbreiding voor Delfzijl RP bovenop Dispatch en MDT.

## Features v0.1

- `/ambulance`
- Ambulance job-check
- Dienststatus aan/uit
- Ziekenhuis blip
- Ziekenhuis check-in
- Medische opslag via ox_inventory stash
- Patiënt reanimeren
- Patiënt behandelen
- Medisch dossier bekijken
- Medisch record toevoegen
- Koppeling met MDT en Dispatch

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_ambulance/sql/ambulance.sql
```

2. Voeg toe aan `server.cfg` na MDT/Dispatch:

```cfg
ensure delfzijlrp_ambulance
```

## Command

```text
/ambulance
```

## Vereiste job

Standaard:

```text
ambulance
```

Aanpassen kan in `config.lua`.

## ox_inventory items

Zorg dat deze items bestaan:

```lua
['bandage'] = { label = 'Verband', weight = 100, stack = true, close = true },
['medikit'] = { label = 'Medikit', weight = 500, stack = true, close = true }
```

## Volgende uitbreidingen

- Brancard systeem
- Ambulancegarage koppeling
- Ziekenhuisbedden
- Operatiekamer RP
- Medische facturen naar business/banking
- Verzekering koppeling
- Body status systeem
