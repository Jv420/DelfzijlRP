fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql',
    'es_extended',
    'delfzijlrp_v3_business_core',
    'delfzijlrp_v3_veh_eco',
    'delfzijlrp_v3_rdw_premium'
}
