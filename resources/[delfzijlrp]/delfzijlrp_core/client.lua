local hasSpawned = false

local function closeLoadingScreen()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(800)
end

local function restorePlayerAtSpawn()
    local ped = PlayerPedId()
    local spawn = Config.DefaultSpawn or vector4(-1037.72, -2737.87, 20.17, 328.0)

    RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
    SetEntityCoordsNoOffset(ped, spawn.x, spawn.y, spawn.z, false, false, false)
    SetEntityHeading(ped, spawn.w or 0.0)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, false)
    SetEntityInvincible(ped, false)
    NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.w or 0.0, true, true, false)
    ClearPedTasksImmediately(ped)
    closeLoadingScreen()
end

local function safeSpawnFallback()
    if hasSpawned then return end

    local spawn = Config.DefaultSpawn or vector4(-1037.72, -2737.87, 20.17, 328.0)
    local ok = pcall(function()
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
            restorePlayerAtSpawn()
            print(('[%s] Spawn fallback uitgevoerd.'):format(Config.ServerName))
        end)
    end)

    if not ok then
        restorePlayerAtSpawn()
        print(('[%s] Basis spawn herstel uitgevoerd.'):format(Config.ServerName))
    end
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
