local function openIdentity()
    local data = lib.callback.await('delfzijlrp_v3_identity_engine:server:getMine', false)
    if not data then
        lib.notify({ title = 'Identity Engine', description = Config.Text.noData, type = 'error' })
        return
    end

    lib.registerContext({
        id = 'drp_identity_menu',
        title = 'Mijn identiteit',
        options = {
            { title = 'Burgernummer', description = data.citizen_id or 'onbekend', readOnly = true },
            { title = 'Naam', description = data.display_name or 'onbekend', readOnly = true },
            { title = 'Telefoonnummer', description = data.phone_number or 'onbekend', readOnly = true },
            { title = 'Adres', description = data.address or Config.DefaultAddress, readOnly = true },
            { title = 'Adres wijzigen', description = 'Koppel later aan Kadaster', onSelect = function()
                local input = lib.inputDialog('Adres wijzigen', {
                    { type = 'input', label = 'Nieuw adres', required = true }
                })
                if input then TriggerServerEvent('delfzijlrp_v3_identity_engine:server:setAddress', input[1]) end
            end },
            { title = 'Rijbewijscategorieën', description = data.driving_categories or '{}', readOnly = true },
            { title = 'Documenthistorie', description = data.document_history or '[]', readOnly = true }
        }
    })
    lib.showContext('drp_identity_menu')
end

CreateThread(function()
    Wait(6000)
    TriggerServerEvent('delfzijlrp_v3_identity_engine:server:ensure')
end)

RegisterCommand(Config.Command, openIdentity, false)
