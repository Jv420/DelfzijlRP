# Delfzijl RP MDT v2

Centrale MDT/tablet voor Delfzijl RP hulpdiensten en juridische systemen.

## Features v0.2

- `/mdt2`
- `/mdt`
- Jobtoegang voor police, ambulance, fire, mechanic, judge, lawyer en customs
- Personen zoeken op naam of Delfzijl ID
- Persoonsdossier bekijken
- Voertuigen van persoon bekijken
- Medische records bekijken
- Rechtbankdossiers bekijken
- Boetes bekijken en registreren
- MDT-notities toevoegen
- RDW/voertuig zoeken op kenteken, VIN of model
- Voertuigdossier bekijken
- Voertuignotities toevoegen
- Dispatch meldingen bekijken
- Centrale auditlogs
- Compat event voor bestaande fine-koppeling

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_mdt_v2/sql/mdt_v2.sql
```

2. Voeg toe aan `server.cfg` na identity, dispatch, voertuigen, ambulance en court:

```cfg
ensure delfzijlrp_mdt_v2
```

## Commands

```text
/mdt2
/mdt
```

## Gebruikte tabellen

Deze resource leest bestaande Delfzijl RP tabellen:

```text
delfzijlrp_identities
delfzijlrp_vehicle_registry
delfzijlrp_dispatch_reports
delfzijlrp_medical_records
delfzijlrp_court_cases
```

Deze resource maakt eigen tabellen:

```text
delfzijlrp_mdt_notes
delfzijlrp_mdt_fines
delfzijlrp_mdt_audit
```

## Volgende uitbreidingen

- Volledige NUI tablet
- Dispatch status in MDT
- Foto's en bewijsstukken
- ANPR meldingen
- Bodycam/dashcam logs
- Realtime eenhedenkaart
- Rolgebaseerde permissies per tabblad
