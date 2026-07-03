CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(250)
    end

    print(('[%s] Core client geladen.'):format(Config.ServerName))
end)
