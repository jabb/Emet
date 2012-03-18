#!/usr/bin/luajit

local StatusTable = {
    -- Health
    ['C'] = {
        icon = 'C',
        name = 'Clay',
        desc = 'Absorbs 1.',
        kind = 'health',
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            '$defender\'s clay shell crumbles a bit!',
            '$defender staggers.',
            '$defender is missing a few chunks.',
            '$defender\'s clay makes a crunch sound.',
        },
    },
    ['F'] = {
        icon = 'F',
        name = 'Flesh',
        desc = 'Absorbs 1.',
        kind = 'health',
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            '$attacker draws some of $defender\'s blood!',
            '$defender is hurt!',
        },
    },
    ['S'] = {
        icon = 'S',
        name = 'Stone',
        desc = 'Absorbs 1.',
        kind = 'health',
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            '$defender chips.',
        },
    },
    ['M'] = {
        icon = 'M',
        name = 'Metal',
        desc = 'Absorbs 1.',
        kind = 'health',
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            '$defender clinks.',
        },
    },
    -- Armor

    -- Skills
    ['D'] = {
        icon = 'D',
        name = 'Dodge',
        desc = 'Dodges an attack.',
        kind = 'skill',
        absorbs = 0,
        triggerFirst = function(info)
            info.stop = '$defender dodged!'
        end,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            '',
        },
    },
    -- Magic

    -- Special
    ['W'] = {
        icon = 'W',
        name = 'Weakness',
        desc = 'A vulnerability.',
        kind = 'special',
        absorbs = 0,
        triggerFirst = function(info)
            info.ap = info.ap * 2
        end,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            '$attacker exposes a weakness!',
        },
    },
}

local ActionTable = {
    ['Pound'] = {
        name = 'Pound',
        desc = 'A punch or jab.',
        kind = 'bump',
        triggerFirst = function(info)
            local r = math.random()
            if r <= 0.25 then
                info.ap = info.ap * 2
            elseif r <= 0.50 then
                info.ap = 0
            end
        end,
        trigger = nil,
        flavorTexts = {
            ['health'] = {
                '$attacker punches $defender.',
                '$attacker jabs $defender.'
            },
            ['armor'] = {
                '$attacker punches $defender.',
                '$attacker jabs $defender.'
            },
            ['skill'] = {
                '$attacker punches $defender.',
                '$attacker jabs $defender.'
            },
            ['magic'] = {
                '$attacker punches $defender.',
                '$attacker jabs $defender.'
            },
            ['default'] = {
                '$attacker punches $defender.',
                '$attacker jabs $defender.'
            },
        },
    },
    ['Maul'] = {
        name = 'Maul',
        desc = 'A bludgeoning attack. Excellent against Clay.',
        kind = 'bump',
        triggerFirst = nil,
        trigger = function(info)
            if math.random() <= 0.10 and info.status.kind == 'health' then
                info.forceRemove = true
            end
        end,
        flavorTexts = {
            ['health'] = {
                '$attacker mauls $defender.'
            },
            ['armor'] = {
                '$attacker mauls $defender.'
            },
            ['skill'] = {
                '$attacker mauls $defender.'
            },
            ['magic'] = {
                '$attacker mauls $defender.'
            },
            ['default'] = {
                '$attacker mauls $defender.'
            },
        },
    },
    ['Expose'] = {
        name = 'Expose',
        desc = 'Exposes a weakness in the enemy.',
        kind = 'bump',
        triggerFirst = function(info)
            local numW = info.defender:countStatusIcons('W')
            for i=numW, info.base_ap - 1 do
                info.defender:insertStatus('W')
            end
            info.stop = ''
        end,
        trigger = nil,
        flavorTexts = {
            ['health'] = {
                '$attacker exposes $defender.'
            },
            ['armor'] = {
                '$attacker exposes $defender.'
            },
            ['skill'] = {
                '$attacker exposes $defender.'
            },
            ['magic'] = {
                '$attacker exposes $defender.'
            },
            ['default'] = {
                '$attacker exposes $defender.'
            },
        },
    },
    ['Rust'] = {
        name = 'Rust',
        desc = 'Drenches the enemy in water. (Good against Metal and Armor)',
        kind = 'bump',
        triggerFirst = function(info)
            if info.status.icon == 'M' or info.status.kind == 'Armor' then
                info.ap = info.ap * 2
            else
                info.ap = math.ceil(info.ap / 2)
            end
        end,
        trigger = nil,
        flavorTexts = {
            ['health'] = {
                '$attacker drenches $defender.'
            },
            ['armor'] = {
                '$attacker drenches $defender.'
            },
            ['skill'] = {
                '$attacker drenches $defender.'
            },
            ['magic'] = {
                '$attacker drenches $defender.'
            },
            ['default'] = {
                '$attacker drenches $defender.'
            },
        },
    },
}

local function GenerateFlavorText(info)
    local str_table = {}
    local repl = {
        attacker = info.attacker._nick:gsub('(%w)([%w\']*)', function(f, r) return f:upper() .. r:lower() end),
        defender = info.defender._nick:gsub('(%w)([%w\']*)', function(f, r) return f:upper() .. r:lower() end),
        dmg = info.dmg,
    }
    local flavor = nil

    if info.stop and info.stop ~= '' then
        flavor = string.gsub(info.stop, '%$(%w+)', repl)
        table.insert(str_table, flavor)
    else
        local removed_table = {}
        local max = nil

        for i, v in ipairs(info.removed) do
            if removed_table[v] then
                removed_table[v] = removed_table[v] + 1
            else
                removed_table[v] = 1
            end

            if not max then max = v end

            if removed_table[v] > removed_table[max] then max = v end
        end

        if StatusTable[info.removed[1]] and StatusTable[info.removed[1]].kind and
           ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind] then
            flavor = ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind][math.random(1, #ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind])]
        else
            flavor = ActionTable[info.action.name].flavorTexts['default'][math.random(1, #ActionTable[info.action.name].flavorTexts['default'])]
        end
        if flavor ~= '' then
            flavor = string.gsub(flavor, '%$(%w+)', repl)
            table.insert(str_table, flavor)
        end

        if max then
            flavor = StatusTable[max].flavorTexts[math.random(1, #StatusTable[max].flavorTexts)]
            if flavor ~= '' then
                flavor = string.gsub(flavor, '%$(%w+)', repl)
                table.insert(str_table, flavor)
            end
        end
    end

    flavor = string.gsub('$defender loses $dmg health!', '%$(%w+)', repl)
    table.insert(str_table, flavor)

    return str_table
end

Emet = {
    ActionTable = ActionTable,
    BumpActions = {'Pound', 'Maul', 'Expose'},
    SpecialActions = {},
    StatusTable = StatusTable,
    HealthStatuses = {'C', 'F', 'S', 'M'},
    ArmorStatuses = {},
    SkillStatuses = {'D'},
    SpecialStatuses = {'W'},

    GenerateFlavorText = GenerateFlavorText,

    Dungeon = nil,
    Enemies = nil,
    Player = nil,
    PlayerScore = 0,

    ConsoleWidth = 80,
    ConsoleHeight = 24,

    DungeonX = 1,
    DungeonY = 5,
    DungeonWidth = 60,
    DungeonHeight = 20,

    StatsX = 61,
    StatsY = 5,
    StatsWidth = 20,
    StatsHeight = 10,

    InfoX = 61,
    InfoY = 15,
    InfoWidth = 20,
    InfoHeight = 10,

    MessengerX = 1,
    MessengerY = 1,
    MessengerWidth = 80,
    MessengerHeight = 4,

    UpgradesX = 1,
    UpgradesY = 1,
    UpgradesWidth = 80,
    UpgradesHeight = 24,

    Messenger = nil,
    Stats = nil,
    Info = nil,
    Upgrades = nil,
}

return Emet
