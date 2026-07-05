# De2Kolommer Delfzijl - Premium Loods

De resource gebruikt nu een bereikbare werkplaatslocatie rond:

```txt
724.42, -1088.74, 22.17
```

## Wat is toegevoegd

- Loodsdeur open/dicht via target en menu
- Brug/serviceplek in de loods
- Reparatie, wassen, APK en tuning
- Gele sleep caddy
- Gele sleepwagens
- Werkplaatsopslag

## Belangrijk

De huidige loodsdeur is een script-object. Voor een echte gebouwde loods met interieur heb je later een MLO/YMAP nodig. Deze resource is daar al logisch op voorbereid: je hoeft dan alleen de coords in `config.lua` te vervangen.

## Aanbevolen server.cfg

```cfg
ensure delfzijlrp_v2_lscustom
ensure delfzijlrp_v2_kolommer
```

## Command

```txt
/kolommer
```

## Testplan

1. Restart resource.
2. Ga naar de nieuwe blip.
3. Open `/kolommer`.
4. Zet de loodsdeur open.
5. Rij auto naar binnen.
6. Test reparatie, tuning en APK.
7. Spawn gele sleepwagen.
