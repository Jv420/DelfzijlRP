fx_version 'cerulean'
game 'gta5'

author 'Delfzijl RP'
description 'Delfzijl RP MDT v2 - centrale tablet voor hulpdiensten, RDW, dossiers en dispatch'
version '0.2.0'

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

files {
    'sql/*.sql'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'es_extended',
    'delfzijlrp_identity',
    'delfzijlrp_dispatch'
}

lua54 'yes'
