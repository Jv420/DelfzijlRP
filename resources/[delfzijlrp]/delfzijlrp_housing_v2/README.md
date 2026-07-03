# Delfzijl RP Housing v2

Kadaster- en woningensysteem voor Delfzijl RP.

## Features v0.2

- `/kadaster`
- `/huis`
- Kadasterbalie
- Panden met adres, postcode en kadastraal nummer
- WOZ waarde
- Bouwjaar
- Koop en huur
- Overdrachtskosten
- Pandtoegang delen
- Meerdere opslagtypes:
  - Algemene opslag
  - Kledingkast
  - Koelkast
- Interieur teleport
- Woonboot/havenwoning voorbeeld
- Kadasterlogs
- ox_target interacties

## Installatie

1. Importeer SQL:

```sql
resources/[delfzijlrp]/delfzijlrp_housing_v2/sql/housing_v2.sql
```

2. Voeg toe aan `server.cfg` na identity, banking2 en ox_inventory:

```cfg
ensure delfzijlrp_housing_v2
```

## Commands

```text
/kadaster
/huis
```

## Belangrijk

Deze resource kan naast `delfzijlrp_housing` draaien tijdens testen. Later kun je kiezen welke versie je actief houdt.

## Volgende uitbreidingen

- Telefoon woning-app
- Woninggarage koppeling
- Hypotheek en maandlasten
- Woningcorporatie job
- Onderhoudsmeldingen
- Deurbel systeem
- Woonboot extra interieurs
- Bedrijfspanden koppelen aan business
