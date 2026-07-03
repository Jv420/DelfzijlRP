# Delfzijl RP Plate Pack

Deze resource is een placeholder voor Nederlandse gele kentekenplaten.

## Wat deze resource doet

- Houdt kenteken-textures gescheiden van de garage- en vehicledealer-code.
- Laat je later makkelijk een `.ytd` texturebestand plaatsen in `stream/`.
- De kentekenlogica zelf staat in `delfzijl_vehicledealer` en `delfzijlrp_garages`.

## Belangrijk

GTA/FiveM kentekenplaten zijn afhankelijk van vehicle textures, plate textures en soms vehicle meta. De code kan Nederlandse kentekens genereren zoals `12-ABC-3`, maar de gele plaatkleur komt uit een texture/mod.

## Installatie later

Plaats je eigen gemaakte of legaal verkregen texturebestand hier:

```text
resources/[delfzijlrp]/delfzijlrp_platepack/stream/
```

Voorbeeld:

```text
stream/vehshare.ytd
```

Daarna in `server.cfg`:

```cfg
ensure delfzijlrp_platepack
```

Commit geen betaalde of niet-gelicentieerde bestanden in een publieke GitHub repo.
