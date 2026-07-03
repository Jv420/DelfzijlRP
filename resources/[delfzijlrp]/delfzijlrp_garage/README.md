# Delfzijl RP Garage

Persoonlijk garage- en depot-systeem voor Delfzijl RP.

## Features v0.1

- `/garage`
- `/impound` voor politie
- Persoonlijke voertuigen ophalen
- Voertuigen stallen
- Meerdere garages
- Depot/impound
- RDW/vehicle registry koppeling
- Eigenaarchecks via `owned_vehicles`
- Extra garage status SQL
- ox_target interacties

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_garage/sql/garage.sql
```

2. Voeg toe aan `server.cfg` na `delfzijlrp_vehicles`:

```cfg
ensure delfzijlrp_garage
```

## Commands

```text
/garage
/impound
```

## Belangrijk

Deze resource gebruikt de bestaande ESX tabel:

```text
owned_vehicles
```

Daarnaast gebruikt hij extra statusdata in:

```text
delfzijlrp_garage_states
```

## Volgende uitbreidingen

- Garage-app in telefoon NUI
- Bedrijfsgarages
- Groepsgarages
- Woninggarages
- Politie/ANWB garages
- Vehicle preview UI
- Impound reden en staff/politie logs
