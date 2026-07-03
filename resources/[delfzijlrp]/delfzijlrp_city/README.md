# Delfzijl RP City

Centrale gemeente-resource voor Delfzijl RP.

## Features v0.1

- `/gemeente`
- `/gemeenteraad`
- Gemeentehuis met ox_target
- Burgerprofiel
- Gemeenteservices met betaling naar gemeentekas
- Vergunningaanvragen
- Gemeentelijk beheer voor job `government`
- Openbare werken meldingen
- Gemeentekas
- Gemeentelogs
- Belastingaanslagen
- Belasting betalen
- Belasting annuleren door gemeente

## Belastingtypes

- Inkomstenbelasting
- Onroerendezaakbelasting
- Motorrijtuigenbelasting
- Bedrijfsbelasting
- Havenheffing
- Administratiekosten
- Overige gemeentebelasting

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_city/sql/city.sql
```

2. Voeg toe aan `server.cfg` na identity en banking2:

```cfg
ensure delfzijlrp_city
```

## Commands

```text
/gemeente
/gemeenteraad
```

## Vereiste job voor beheer

```text
government
```

Aanpassen kan in `config.lua`.

## Volgende uitbreidingen

- Automatische voertuigbelasting
- Automatische woningbelasting via housing_v2
- Bedrijfsbelasting via business_v2
- Telefoon gemeente-app
- Gemeenteraad stemmingen
- Subsidies
