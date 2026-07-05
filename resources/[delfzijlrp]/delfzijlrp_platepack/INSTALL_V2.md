# Delfzijl RP PlatePack v2

## Doel

Deze resource streamt jouw Nederlandse kentekenplaattexture via:

```txt
stream/vehshare.ytd
```

De RDW/dealer scripts zetten alleen de kentekentekst. De gele kleur komt uit `vehshare.ytd`.

## Vereiste mapstructuur

```txt
resources/[delfzijlrp]/delfzijlrp_platepack/
├── fxmanifest.lua
├── config.lua
├── client.lua
└── stream/
    └── vehshare.ytd
```

## Server.cfg

Zet platepack laat genoeg in de lijst, na voertuigpacks die mogelijk ook `vehshare.ytd` streamen:

```cfg
ensure PLOKS_CARS
ensure delfzijlrp_platepack
```

Als een ander vehiclepack ook een `vehshare.ytd` heeft, kan die jouw Nederlandse platen overschrijven. In dat geval moet `delfzijlrp_platepack` NA dat pack starten.

## Test

1. Start server opnieuw.
2. Join opnieuw na cache legen.
3. Stap in of sta naast een auto.
4. Gebruik:

```txt
/platepacktest
```

Als de kentekentekst verandert maar de plaat niet geel is, dan werkt het script wel maar wordt de texture niet geladen.

## FiveM cache legen

Sluit FiveM en verwijder:

```txt
%localappdata%\FiveM\FiveM.app\data\cache
%localappdata%\FiveM\FiveM.app\data\server-cache
%localappdata%\FiveM\FiveM.app\data\server-cache-priv
%localappdata%\FiveM\FiveM.app\data\nui-storage
```

Niet `game-storage` verwijderen.
