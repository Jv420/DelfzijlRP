fx_version 'cerulean'
game 'gta5'

author 'Delfzijl RP'
description 'Delfzijl RP Police - politie tools, RDW controle, boetes en bureau functies'
version '0.1.0'

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
    'ox_target',
    'oxmysql',
    'es_extended',
    'delfzijlrp_dispatch',
    'delfzijlrp_mdt',
    'delfzijlrp_vehicles'
}

lua54 'yes'
