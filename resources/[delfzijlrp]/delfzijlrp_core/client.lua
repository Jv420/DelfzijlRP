local hasSpawned = false

local function closeLoadingScreen()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(800)
end

local function safeSpawnFallback()
    if hasSpawned then return end
    if not exports.spawnmanager then return end

    local spawn = Config.DefaultSpawn or vector4(-1037.72, -2737.87, 20.17, 328.0)

    exports.spawnmanager:setAutoSpawn(false)
    exports.spawnmanager:spawnPlayer({
        x = spawn.x,
        y = spawn.y,
        z = spawn.z,
        heading = spawn.w or 0.0,
        model = `mp_m_freemode_01`,
        skipFade = false
    }, function()
        hasSpawned = true
        closeLoadingScreen()
        print(('[%s] Spawn fallback uitgevoerd.'):format(Config.ServerName))
    end)
end

AddEventHandler('playerSpawned', function()
    hasSpawned = true
    closeLoadingScreen()
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(250)
    end

    print(('[%s] Core client geladen.'):format(Config.ServerName))
    closeLoadingScreen()

    Wait(8000)
    safeSpawnFallback()
end)
