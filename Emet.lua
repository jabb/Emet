#!/usr/bin/luajit

local StatusTable = {
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
}

local ActionTable = {
    ['Maul'] = {
        name = 'Maul',
        desc = 'A bludgeoning attack. Excellent against Clay.',
        kind = 'bump',
        triggerFirst = nil,
        trigger = function(info)
            if math.random(1, 100) <= 25 and info.status.kind == 'health' then
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
}

local function GenerateFlavorText(info)
    local str_table = {}
    local repl = {
        attacker = info.attacker._nick:gsub('(%w)([%w\']*)', function(f, r) return f:upper() .. r:lower() end),
        defender = info.defender._nick,
        dmg = info.dmg,
    }
    local flavor = nil

    if info.stop and info.stop ~= '' then
        flavor = string.gsub(info.stop, '%$(%w+)', repl)
        table.insert(str_table, flavor)
    elseif #info.removed > 0 then
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

        if ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind] then
            flavor = ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind][math.random(1, #ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind])]
        else
            flavor = ActionTable[info.action.name].flavorTexts['default'][math.random(1, #ActionTable[info.action.name].flavorTexts['default'])]
        end
        if flavor ~= '' then
            flavor = string.gsub(flavor, '%$(%w+)', repl)
            table.insert(str_table, flavor)
        end

        flavor = StatusTable[max].flavorTexts[math.random(1, #StatusTable[max].flavorTexts)]
        if flavor ~= '' then
            flavor = string.gsub(flavor, '%$(%w+)', repl)
            table.insert(str_table, flavor)
        end
    end

    flavor = string.gsub('$defender loses $dmg health!', '%$(%w+)', repl)
    table.insert(str_table, flavor)

    return table.concat(str_table, ' ')
end

Emet = {
    ActionTable = ActionTable,
    StatusTable = StatusTable,

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

    Messenger = nil,
    Stats = nil,
    Info = nil,
}

return Emet
