
function Core.Functions.CreateJob(jobName, label, config, override)
    if not jobName or not label then
        return error('nojobName')
    end

    if not config.grades or type(config.grades) ~= 'table' then
        return error('must be table')
    end

    if Shared.Jobs[jobName] and not override then
        return Shared.Jobs[jobName] 
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
    Player.Job.label = Shared.Jobs[job].label 
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


RegisterNetEvent('playerJoining', function() -- perhaps another way?
    local source = source
    TriggerClientEvent('kCore:syncJobs', source, Shared.Jobs)
end)
