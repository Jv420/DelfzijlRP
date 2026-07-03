# Delfzijl RP Police

Politie-uitbreiding voor Delfzijl RP bovenop MDT, Dispatch en RDW.

## Features v0.1

- `/politie`
- Politie job-check
- Dienststatus aan/uit
- Politiebureau blip
- Bewijskluis via ox_inventory stash
- Uitrustingspunt via ox_inventory stash
- RDW/kentekencontrole
- Gestolen-status zetten/verwijderen
- Inbeslagname-status zetten/verwijderen
- Boetes uitschrijven
- Koppeling met MDT en Dispatch
- Politielogs in database

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_police/sql/police.sql
```

2. Voeg toe aan `server.cfg` na MDT/Dispatch/RDW:

```cfg
ensure delfzijlrp_police
```

## Command

```text
/politie
```

## Vereiste job

Standaard:

```text
police
```

Aanpassen kan in `config.lua`.

## Volgende uitbreidingen

- Handboeien en escort
- Cellencomplex
- Rijbewijs innemen
- Wapenvergunningen
- Bodycam/dashcam
- ANPR-scanner
- Politie garage koppeling
- Bewijsmateriaal koppeling met CrimePlus
