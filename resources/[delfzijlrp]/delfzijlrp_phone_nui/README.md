# Delfzijl RP Phone NUI

Moderne NUI telefoonbasis voor Delfzijl RP.

## Features v0.1

- `/phone`
- `/telefoon2`
- F2 keybind
- Telefoon item-check via ox_inventory
- Nederlandse telefoon UI
- Home screen met apps
- Delfzijl ID app
- Bank app met IBAN/saldo/transacties
- Shortcuts naar bestaande resources:
  - 112
  - Marktplaats
  - RDW
  - Bedrijven
  - Woning
  - Groep
  - Taxi
- Instellingen voor accentkleur/wallpaper
- SQL settings-tabel

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_phone_nui/sql/phone_nui.sql
```

2. Voeg toe aan `server.cfg` na identity en banking2:

```cfg
ensure delfzijlrp_phone_nui
```

3. Zorg dat `phone` bestaat in `ox_inventory/data/items.lua`:

```lua
['phone'] = {
    label = 'Telefoon',
    weight = 250,
    stack = false,
    close = true,
    description = 'Smartphone voor Delfzijl RP.'
}
```

## Testen naast oude telefoon

Je kunt deze resource naast `delfzijlrp_phone` testen omdat de commands anders zijn:

```text
/phone
/telefoon2
```

De oude gebruikt `/telefoon`.

## Volgende uitbreidingen

- Native bank overschrijven in NUI
- Native Marktplaats UI
- SMS/chat systeem
- Bellen
- Taxi bestellen via app
- RDW voertuig-app
- Woning-app
- Foto/camera app
- React/Vite upgrade
