# Delfzijl RP CrimePlus

CrimePlus is een veilige RP-gameplay resource voor incidenten, alarmen, cooldowns en dispatch-koppeling.

## Features v0.2

- Winkelincidenten
- ATM-incidenten
- Havencontainer-incidenten
- Server-side itemchecks
- Cooldowns per locatie
- Dispatch-koppeling
- Beloningen via ESX accounts/items
- Database logging
- ox_target interacties

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_crimeplus/sql/crimeplus.sql
```

2. Voeg toe aan `server.cfg` na dispatch:

```cfg
ensure delfzijlrp_crimeplus
```

3. Zorg dat deze items bestaan in `ox_inventory/data/items.lua`:

```lua
['lockpick'] = { label = 'Lockpick', weight = 80, stack = true, close = true },
['advancedlockpick'] = { label = 'Geavanceerde lockpick', weight = 120, stack = true, close = true },
['drill'] = { label = 'Boormachine', weight = 2500, stack = false, close = true },
['electronics'] = { label = 'Elektronica', weight = 500, stack = true, close = true },
['tools'] = { label = 'Gereedschap', weight = 750, stack = true, close = true }
```

## Belangrijk

Deze resource is bedoeld voor fictieve FiveM RP-gameplay. Het bevat geen echte instructies of echte procedures.

## Volgende uitbreidingen

- Gang-systeem
- Bewijsmateriaal voor politie
- CCTV/ANPR koppeling
- Dynamische risico's
- Security job koppeling
- MDT incidenthistorie
