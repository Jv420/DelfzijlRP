# Delfzijl RP Vehicles

Overkoepelend voertuigsysteem voor Delfzijl RP.

## Features v0.1

- RDW-register per voertuig
- Unieke VIN per voertuig
- APK-datum
- Verzekeringstype en vervaldatum
- Kilometerstand
- Gestolen-status
- Voertuigsleutels
- Sleutels delen met spelers
- Voertuig overschrijven naar andere speler

## Commands

```text
/rdw [kenteken]
/autosleutels spelerID [kenteken]
/overschrijven spelerID [kenteken]
```

Zonder kenteken gebruikt het script het dichtstbijzijnde voertuig.

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_vehicles/sql/vehicles.sql
```

2. Voeg toe aan `server.cfg` na `delfzijl_vehicledealer`:

```cfg
ensure delfzijlrp_vehicles
```

3. Koppel je dealer na aankoop aan:

```lua
exports['delfzijlrp_vehicles']:CreateRDWRecord(source, plate, {
    model = model,
    brand = brand,
    color = color
})
```

## Database

Deze resource gebruikt naast `owned_vehicles` twee eigen tabellen:

- `delfzijlrp_vehicle_registry`
- `delfzijlrp_vehicle_keys`

## Let op

Dit is v0.1. Later kunnen we uitbreiden met:

- RDW UI
- Politie MDT koppeling
- ANWB APK-keuring UI
- Verzekeringskantoor
- Schadehistorie
- Onderhoudshistorie
- Telefoon-app
