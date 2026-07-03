# Delfzijl RP Admin

Staffmenu en reportsysteem voor Delfzijl RP.

## Features v0.1

- `/staff`
- `/report`
- Online spelers bekijken
- Teleport naar speler
- Speler naar staff brengen
- Heal
- Revive via `esx_ambulancejob`
- Freeze toggle
- Voertuig repareren
- Voertuig schoonmaken
- Voertuig verwijderen
- Reports bekijken/sluiten
- Stafflogs in database

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_admin/sql/admin.sql
```

2. Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_admin
```

3. Zorg dat je ESX groups goed staan:

```lua
admin
superadmin
owner
mod
```

Aanpassen kan in `config.lua`.

## Commands

```text
/staff
/report
```

## Volgende uitbreidingen

- NUI staffpanel
- Discord webhook logs
- Ban/warn systeem
- Report claimen
- Staff duty systeem
- Spectate
- NoClip
- Screenshot/log koppeling
