fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua',
    'client_tools.lua',
    'client_events.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'server_tools.lua',
    'server_events.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'oxmysql',
    'es_extended',
    'delfzijlrp_rdw'
}
