fx_version 'cerulean'
game 'gta5'

author 'Delfzijl RP'
description 'Delfzijl RP Dispatch - 112, ANWB, taxi en service meldingen'
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
    'oxmysql',
    'es_extended'
}

lua54 'yes'
