local ESX = exports['es_extended']:getSharedObject()

CreateThread(function()
    print(('[%s] Core server geladen.'):format(Config.ServerName))
end)

RegisterNetEvent('delfzijlrp_core:server:requestServerName', function()
    local source = source
    TriggerClientEvent('delfzijlrp_core:client:receiveServerName', source, Config.ServerName)
end)
