function Core.Functions.CreateJob(jobName, label, config, override)
    if not jobName or not label then
        return error('nojobName')
    end

    if not config.grades or type(config.grades) ~= 'table' then
        return error('must be table')
    end

    if Shared.Jobs[jobName] and not override then
        return error(string.format('job %s already exists', jobName))
    end

    local job = {
        id = jobName,
        label = label,
        grades = {}
    }

    if config.grades[0] then
        if config.grades[0].rank ~= 0 then
            for k, v in pairs(config.grades) do
                v.rank = v.rank - 1
            end
        end
    else
        if config.grades[1].rank ~= 0 then
            for k, v in pairs(config.grades) do
                v.rank = v.rank - 1
            end
        end
    end

    for i, grade in pairs(config.grades) do
        if not grade or not grade.name or not grade.salary or not grade.rank then
            return error(string.format('invalid grade config for job %s at index %d', jobName, i))
        end

        job.grades[grade.rank] = {
            name = grade.name,
            salary = grade.salary,
            rank = grade.rank
        }
    end
    Shared.Jobs[jobName] = job
    TriggerClientEvent('kCore:syncJobs', -1, Shared.Jobs)
    return job
end
exports('CreateJob', Core.Functions.CreateJob)

function Core.Functions.SetPlayerJob(source, job, grade)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then
        return false
    end

    if not Shared.Jobs[job] then
        print("^1Error: Job does not exist^7:", job, grade)
        return false
    end

    if not Shared.Jobs[job].grades[grade] then
        print("^1Error: Job grade does not exist^7:", job, grade)
        return false
    end

    Player.Job.name = job
    Player.Job.grade = grade
    Player.Job.salary = Shared.Jobs[job].grades[grade].salary
    Player.Job.grade_label = Shared.Jobs[job].grades[grade].name

    Player.Functions.Save()

    return true
end
exports('SetPlayerJob', Core.Functions.SetPlayerJob)

function Core.Functions.GetJob(job)
    if not Shared.Jobs[job] then
        print("^1Error: Job does not exist^7:", job)
        return false
    end

    return Shared.Jobs[job]
end
exports('GetJob', Core.Functions.GetJob)

function Core.Functions.GetPlayerJob(source)
    local Player = Core.Functions.GetPlayer(source)
    if not Player then
        return false
    end

    return Player.Job
end
exports('GetPlayerJob', Core.Functions.GetPlayerJob)

function Core.Functions.GetAllJobs()
    return Shared.Jobs
end
exports('GetAllJobs', Core.Functions.GetAllJobs)

RegisterCommand('createPolice', function(source, args)
    Core.Functions.CreateJob("police", "LSPD", {
        grades = {{
            name = 'Cadet',
            salary = 1000,
            rank = 1
        }, {
            name = 'Officer',
            salary = 1500,
            rank = 2
        }, {
            name = 'Sergeant',
            salary = 2000,
            rank = 3
        }}
    })

    TriggerClientEvent('kCore:debugJob', source)
end)

RegisterCommand('createFire', function(source, args)
    Core.Functions.CreateJob("fire", "LSFD", {
        grades = { [0] = {
            name = 'Paramedic',
            salary = 1000,
            rank = 0
        }, [1] = {
            name = 'Firefighter',
            salary = 1500,
            rank = 1
        }, [2] = {
            name = 'Chief',
            salary = 2000,
            rank = 2
        }}
    })

    TriggerClientEvent('kCore:debugJob', source)
end)

RegisterCommand('setjob', function(source, args)
    local playerId = tonumber(args[1])
    local job = args[2]
    local grade = tonumber(args[3])

    if source == 0 then 
        if not playerId or not job or not grade then
            print("^1Usage: setjob [playerID] [job] [grade]^7")
            return
        end

        if Core.Functions.SetPlayerJob(playerId, job, grade) then
            print("^2Successfully changed job of player " .. playerId .. " to " .. job .. " grade " .. grade .. "^7")
        else
            print("^1Failed to change job. Player might not exist or invalid job/grade specified.^7")
        end
    else 
        if not playerId or not job or not grade then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Usage: /setjob [playerID] [job] [grade]"}
            })
            return
        end

        if Core.Functions.SetPlayerJob(playerId, job, grade) then
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 0},
                args = {"SYSTEM",
                        "Successfully changed job of player " .. playerId .. " to " .. job .. " grade " .. grade}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"SYSTEM", "Failed to change job. Player might not exist or invalid job/grade specified."}
            })
        end
    end
end, false)

RegisterNetEvent('playerJoining', function() -- perhaps another way?
    local source = source
    TriggerClientEvent('kCore:syncJobs', source, Shared.Jobs)
end)
