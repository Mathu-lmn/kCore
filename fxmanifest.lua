fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Kypos'
description 'kCore Framework | Alpha 0.0.1'
version '0.0.1'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

shared_scripts {
    'libs/*.lua', 
    'shared/**/**'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/load.lua',
    'client/events.lua',
    'client/death.lua',
    'client/hud.lua',
    'client/interface.lua',
    'client/items.lua',
    'client/loops.lua',
    'client/callbacks.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/economy.lua',
    'server/needs.lua',
    'server/autosave.lua',
    'server/utils.lua',
    'server/commands.lua',
    'server/inventory.lua',
    'server/items.lua',
    'server/callbacks.lua',
    'server/jobs.lua',
    'server/permissions.lua',
}


files {
    'config/client.lua',
    'config/shared.lua',
    'shared/itemImages/*.png',
}
