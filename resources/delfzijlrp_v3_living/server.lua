local ESX = exports['es_extended']:getSharedObject()

local function notify(src, text, kind)
    TriggerClientEvent('ox_lib:notify', src, { title = 'Living Netherlands', description = text, type = kind or 'inform' })
end

CreateThread(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS delfzijlrp_living_daily (
        identifier varchar(64) NOT NULL,
        task_id varchar(64) NOT NULL,
        done_date date NOT NULL,
        reward int NOT NULL DEFAULT 0,
        created_at timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY(identifier, done_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
end)

local function findTask(taskId)
    for _, district in ipairs(Config.Districts) do
        for _, task in ipairs(district.tasks or {}) do
            if task.id == taskId then return task, district end
        end
    end
    return nil, nil
end

lib.callback.register('delfzijlrp_v3_living:server:completeTask', function(source, taskId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, Config.Text.noTask end

    local task = findTask(taskId)
    if not task then return false, Config.Text.noTask end

    local today = os.date('%Y-%m-%d')
    local exists = MySQL.scalar.await('SELECT task_id FROM delfzijlrp_living_daily WHERE identifier = ? AND done_date = ? LIMIT 1', {
        xPlayer.identifier,
        today
    })
    if exists then return false, Config.Text.taskAlready end

    local reward = tonumber(task.reward) or 0
    if reward > 0 then xPlayer.addAccountMoney('bank', reward) end

    MySQL.insert.await('INSERT INTO delfzijlrp_living_daily (identifier, task_id, done_date, reward) VALUES (?, ?, ?, ?)', {
        xPlayer.identifier,
        taskId,
        today,
        reward
    })

    return true, Config.Text.taskDone .. ' Beloning: €' .. reward
end)

RegisterCommand(Config.DailyCommand, function(source)
    TriggerClientEvent('delfzijlrp_v3_living:client:openDaily', source)
end, false)
