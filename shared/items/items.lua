Shared = {}
Shared.Items = {
    ['water'] = {
        itemName = 'water',
        label = 'Water Bottle',
        description = "A nice water bottle",
        image = 'waterbottle.png',
        maxStack = 64,
        unique = false,
        weight = 1,
        size = {
            width = 1,
            height = 2
        },
        rarity = 'drink',
        shouldCloseInventory = true,
        type = 'item'
    },
    ['weapon_specialcarbine_mk2'] = {
        itemName = 'weapon_specialcarbine_mk2',
        label = 'Carbine Rifle',
        description = "Firearm",
        image = 'weapon_specialcarbine_mk2.png',
        maxStack = 1,
        unique = true,
        weight = 1,
        size = {
            width = 3,
            height = 2
        },
        rarity = 'rifle',
        shouldCloseInventory = true,
        type = 'weapon',
        ammoType = 'rifle_ammo'
    },
    ['weapon_assaultrifle'] = {
        itemName = 'weapon_assaultrifle',
        label = 'Assault Rifle',
        description = "Firearm",
        image = 'weapon_assaultrifle.png',
        maxStack = 1,
        unique = true,
        weight = 1,
        size = {
            width = 3,
            height = 2
        },
        rarity = 'rifle',
        shouldCloseInventory = true,
        type = 'weapon',
        ammoType = 'rifle_ammo'
    },


    ['weapon_pistol'] = {
        itemName = 'weapon_pistol',
        label = 'Pistol',
        description = "Firearm",
        image = 'weapon_pistol.png',
        maxStack = 1,
        unique = true,
        weight = 1,
        size = {
            width = 2,
            height = 2
        },
        rarity = 'pistol',
        shouldCloseInventory = true,
        type = 'weapon',
        ammoType = 'pistol_ammo'
    },

    ['rifle_ammo'] = {
        itemName = 'rifle_ammo',
        label = 'Rifle Ammo',
        description = "Ammo",
        image = 'rifle_ammo.png',
        maxStack = 999,
        unique = false,
        weight = 1,
        size = {
            width = 1,
            height = 1
        },
        rarity = 'rifleAmmo',
        shouldCloseInventory = true,
        type = 'item'
    },
    
    ['pistol_ammo'] = {
        itemName = 'pistol_ammo',
        label = 'Pistol Ammo',
        description = "Ammo",
        image = 'pistol_ammo.png',
        maxStack = 999,
        unique = false,
        weight = 1,
        size = {
            width = 1,
            height = 1
        },
        rarity = 'pistolAmmo',
        shouldCloseInventory = true,
        type = 'item'
    },
}