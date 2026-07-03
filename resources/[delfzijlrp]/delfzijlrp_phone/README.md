# Delfzijl RP Phone

Basis telefoon voor Delfzijl RP. Deze versie gebruikt `ox_lib` menu's; later kan dit worden vervangen door een volledige React/NUI telefoon.

## Features v0.1

- Command `/telefoon`
- Keybind F1
- Telefoon-item check via `ox_inventory`
- Delfzijl ID app
- 112/service app
- Advertenties app
- Contacten app
- Snelkoppelingen naar bank, RDW en bedrijven

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_phone/sql/phone.sql
```

2. Voeg item toe aan `ox_inventory/data/items.lua` als die nog niet bestaat:

```lua
['phone'] = {
    label = 'Telefoon',
    weight = 250,
    stack = false,
    close = true,
    description = 'Smartphone voor Delfzijl RP.'
}
```

3. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_phone
```

## Koppelingen

Deze phone v0.1 kan al verbinden met:

- `delfzijlrp_identity`
- `delfzijlrp_dispatch`
- `delfzijlrp_business`
- `delfzijlrp_vehicles`

## Volgende uitbreidingen

- Echte NUI/React telefoon
- Berichten en bellen
- Bank-app native in de telefoon
- Garage-app native in de telefoon
- Marktplaats-app
- Bedrijfs-app
- Taxi-app
- ANWB-app
- Politie/ambulance dienst-apps
