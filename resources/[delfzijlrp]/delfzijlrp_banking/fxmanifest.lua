fx_version 'cerulean'
game 'gta5'

author 'Delfzijl RP'
description 'Delfzijl RP Banking - bank en ATM systeem voor ESX Legacy'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'es_extended'
}

lua54 'yes'
