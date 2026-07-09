# Delfzijl RP Texture Pack v1.0

Professionele FiveM texture-resource voor **Delfzijl RP** met Nederlandse RP-uitstraling.

## Doel

Deze resource is bedoeld als nette basis voor:

- Nederlandse wegen en stoepen
- Delfzijl RP billboards en reclame
- Nederlandse verkeersborden
- Nederlandse winkel- en tankstation-textures
- Verbeterde vegetatie/water/lights
- Serverbranding zonder zware graphics-mods

## Belangrijk

Deze resource bevat bewust nog geen gekopieerde textures uit betaalde of onbekende packs. Gebruik alleen:

1. Eigen gemaakte textures
2. Textures met duidelijke toestemming/licentie
3. Gratis resources waarvan de maker FiveM/servergebruik toestaat

Zo blijft Delfzijl RP veilig en netjes voor GitHub en FiveM.

## Installatie

Plaats de map in je server resources, bijvoorbeeld:

```txt
resources/[delfzijlrp]/delfzijlrp_textures
```

Voeg toe aan `server.cfg`:

```cfg
ensure delfzijlrp_textures
```

Start daarna je server opnieuw of gebruik:

```txt
refresh
ensure delfzijlrp_textures
```

## Mapstructuur

```txt
delfzijlrp_textures/
├── fxmanifest.lua
├── README.md
├── config/
│   └── texturepack.cfg
├── stream/
│   ├── roads/
│   ├── signs/
│   ├── billboards/
│   ├── shops/
│   ├── vehicles/
│   ├── emergency/
│   ├── vegetation/
│   ├── water/
│   └── lights/
└── docs/
    ├── texture-naming-guide.md
    └── optimisation-guide.md
```

## Aanbevolen volgorde in server.cfg

Zet deze resource na je maps/MLO's, zodat texture overrides goed geladen worden:

```cfg
ensure oxmysql
ensure ox_lib
ensure es_extended

# Maps / MLO
ensure delfzijlrp_maps

# Texture pack
ensure delfzijlrp_textures
```

## Versies

### Lite
Voor spelers met lagere PC's. Gebruik vooral 1K/2K textures.

### Balanced
Beste standaard voor Delfzijl RP. Gebruik vooral 2K textures.

### Ultra
Voor screenshots en high-end spelers. Gebruik 4K textures alleen waar het echt zin heeft.

## Tips

- Gebruik niet overal 4K; wegen, billboards en grote gevels zijn belangrijker dan kleine props.
- Test altijd FPS in drukke gebieden.
- Hou originele bestandsnamen aan wanneer je GTA-textures vervangt.
- Maak per categorie kleine commits, bijvoorbeeld `roads`, `signs`, `billboards`.
