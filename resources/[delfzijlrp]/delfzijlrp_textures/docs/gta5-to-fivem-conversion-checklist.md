# GTA 5 naar FiveM Texture Checklist

Je kunt veel GTA 5 texturemods gebruiken als basis voor FiveM, maar test en check altijd eerst licentie + bestandsstructuur.

## 1. Licentie checken

Controleer altijd de README, downloadpagina of `license.txt`.

### Meestal veilig

- De maker zegt dat FiveM/servergebruik toegestaan is.
- De maker zegt dat aanpassen en heruploaden toegestaan is.
- De mod heeft een open licentie zoals MIT, GPL, CC0 of Creative Commons met duidelijke voorwaarden.

### Eerst toestemming vragen

- Er staat alleen `singleplayer only`.
- Er staat niets over heruploaden of servergebruik.
- De maker zegt `do not redistribute`.
- Het is een betaalde pack of gelekte pack.

### Niet gebruiken in public repo/server

- Gestolen/leaked packs.
- Betaalde packs zonder toestemming.
- Packs met echte merken waar je geen toestemming voor hebt, als je die publiek verspreidt.

## 2. Bestanden herkennen

FiveM streamt vaak deze bestanden:

```txt
.ytd  = texture dictionary
.ydr  = drawable/model
.yft  = vehicle/fragment model
.ybn  = collision
.ymap = map placement
.ytyp = archetypes
```

Voor een texturepack zijn vooral `.ytd` belangrijk.

## 3. Mappen uit GTA 5 mods

Veel singleplayer mods komen uit OpenIV met paden zoals:

```txt
x64e.rpf/levels/gta5/vehicles.rpf/
x64h.rpf/levels/gta5/props/roadside/v_traffic_lights.rpf/
update/x64/dlcpacks/.../dlc.rpf/
```

Voor FiveM zet je de relevante `.ytd/.ydr/.yft` bestanden meestal in:

```txt
resources/[delfzijlrp]/delfzijlrp_textures/stream/<categorie>/
```

Voorbeeld:

```txt
stream/roads/
stream/signs/
stream/billboards/
stream/shops/
stream/emergency/
```

## 4. Conversie stappen

1. Download de mod.
2. Lees README/licentie.
3. Pak de mod uit.
4. Zoek de `.ytd`, `.ydr`, `.yft`, `.ymap` bestanden.
5. Plaats alleen de nodige bestanden in de juiste `stream/` map.
6. Start de server met `ensure delfzijlrp_textures`.
7. Test in-game.
8. Check F8-console en serverconsole op errors.
9. Test FPS en texture pop-in.
10. Commit pas daarna naar GitHub.

## 5. Performance regels

- Gebruik 4K alleen voor grote oppervlakken zoals wegen/gevels/billboards.
- Voor kleine props is 1K of 2K genoeg.
- Maak niet één mega-pack met alles tegelijk; test per categorie.
- Verwijder dubbele textures.
- Gebruik geen 8K textures voor normale RP-server gameplay.

## 6. Goede startvolgorde voor Delfzijl RP

1. Roads
2. Signs
3. Billboards
4. Shops/tankstations
5. Emergency branding
6. Vegetation
7. Water
8. Lighting

## 7. Server.cfg

```cfg
ensure delfzijlrp_textures
```

Zet deze resource na je maps/MLO's.

## 8. Belangrijke waarschuwing

Zet geen downloadpacks direct in je public GitHub repo als je niet zeker weet dat herpublicatie mag. Je kunt ze wel lokaal testen op je eigen server, maar publiek delen is iets anders.
