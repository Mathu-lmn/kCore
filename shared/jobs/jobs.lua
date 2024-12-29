Shared.Jobs = {
    ['unemployed'] = {
        id = "unemployed",
        label = "Unemployed",
        grades = {
            [0] = {
                name = 'Unemployed',
                salary = 500,
                rank = 0
            },
        }
    },
}

exports('GetJobs', Shared.Jobs)
