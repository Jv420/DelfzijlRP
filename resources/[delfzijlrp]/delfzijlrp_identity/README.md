# Delfzijl RP Identity

Gemeentehuis- en identiteitssysteem voor Delfzijl RP.

## Features v0.1

- Fictief Delfzijl ID
- ID-profiel aanmaken
- ID-kaart aanvragen
- Paspoort aanvragen
- Rijbewijs aanvragen
- Uittreksel aanvragen
- Documenten als ox_inventory-items met metadata
- Gemeentehuisbalie met ox_target
- Command `/gemeente`

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_identity/sql/identity.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_identity
```

3. Voeg de items toe aan `ox_inventory/data/items.lua`.

## ox_inventory items

```lua
['id_card'] = {
    label = 'ID-kaart',
    weight = 10,
    stack = false,
    close = true,
    description = 'Officiële ID-kaart van Delfzijl RP.'
},

['passport'] = {
    label = 'Paspoort',
    weight = 20,
    stack = false,
    close = true,
    description = 'Paspoort van Delfzijl RP.'
},

['driver_license'] = {
    label = 'Rijbewijs',
    weight = 10,
    stack = false,
    close = true,
    description = 'Rijbewijs voor voertuigen.'
},

['birth_certificate'] = {
    label = 'Uittreksel Basisregistratie',
    weight = 15,
    stack = false,
    close = true,
    description = 'Gemeentelijk uittreksel.'
}
```

## Volgende uitbreidingen

- Politie MDT-koppeling
- RDW-balie koppeling
- Rijschool/examen systeem
- Gemeentejob met medewerkerrechten
- Document tonen aan andere speler
