Config = {}

Config.Debug = false
Config.Command = 'toegang'

Config.Points = {
    {
        id = 'gemeente_baliehal',
        label = 'Gemeentehuis baliehal',
        outside = vector4(-546.72, -203.88, 38.22, 210.0),
        inside = vector4(-546.91, -211.26, 37.65, 30.0),
        radius = 1.8
    },
    {
        id = 'kvk_balie',
        label = 'KVK balie',
        outside = vector4(-552.91, -205.10, 38.22, 180.0),
        inside = vector4(-552.91, -211.26, 37.65, 0.0),
        radius = 1.4
    },
    {
        id = 'kadaster_balie',
        label = 'Kadaster balie',
        outside = vector4(-548.91, -205.10, 38.22, 180.0),
        inside = vector4(-548.91, -211.26, 37.65, 0.0),
        radius = 1.4
    },
    {
        id = 'rdw_balie',
        label = 'RDW balie',
        outside = vector4(-544.91, -205.10, 38.22, 180.0),
        inside = vector4(-544.91, -211.26, 37.65, 0.0),
        radius = 1.4
    },
    {
        id = 'info_balie',
        label = 'Delfzijl RP infobalie',
        outside = vector4(-540.91, -205.10, 38.22, 180.0),
        inside = vector4(-540.91, -211.26, 37.65, 0.0),
        radius = 1.4
    },
    {
        id = 'piricars_showroom',
        label = 'Piricars showroom',
        outside = vector4(-795.62, -220.15, 37.08, 120.0),
        inside = vector4(-788.75, -230.66, 37.08, 117.0),
        radius = 2.0
    },
    {
        id = 'kolommer_loods',
        label = 'De2Kolommer loods',
        outside = vector4(724.42, -1096.30, 22.17, 270.0),
        inside = vector4(724.42, -1088.74, 22.17, 90.0),
        radius = 2.5
    },
    {
        id = 'cafe_stad_lande',
        label = 'Cafe Stad en Lande',
        outside = vector4(-560.72, -181.65, 38.22, 210.0),
        inside = vector4(-560.72, -181.65, 38.22, 30.0),
        radius = 2.0
    }
}

Config.VehiclePoints = {
    {
        id = 'kolommer_garage',
        label = 'De2Kolommer garagepoort',
        outside = vector4(724.42, -1098.80, 22.17, 270.0),
        inside = vector4(724.42, -1072.80, 22.17, 90.0),
        radius = 4.0
    }
}

Config.Text = {
    enter = 'Naar binnen',
    exit = 'Naar buiten',
    vehicleEnter = 'Garage inrijden',
    vehicleExit = 'Garage uitrijden',
    menu = 'Toegangsmenu',
    teleported = 'Toegang gebruikt.'
}
