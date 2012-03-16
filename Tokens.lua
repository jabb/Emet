#!/usr/bin/luajit

local function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local PeekStatus
local RemoveStatus
local InsertStatus
local CountStatusKinds
local CountStatusIcons

local GenerateFlavorText
local HealthOf
local Attack
local NewBeing



local StatusList = {
    ["C"] = {
        icon = "C",
        name = "Clay",
        desc = "Absorbs 1.",
        kind = "health",
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            "$defender's clay shell crumbles a bit'!",
            "$defender staggers.",
            "$defender is missing a few chunks.",
            "$defender's clay makes a crunch sound.",
        },
    },
    ["F"] = {
        icon = "F",
        name = "Flesh",
        desc = "Absorbs 1.",
        kind = "health",
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            "$attacker draws some of $defender's blood!",
            "$defender is hurt!",
        },
    },
    ["S"] = {
        icon = "S",
        name = "Stone",
        desc = "Absorbs 1.",
        kind = "health",
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            "$defender chips.",
        },
    },
    ["M"] = {
        icon = "M",
        name = "Metal",
        desc = "Absorbs 1.",
        kind = "health",
        absorbs = 1,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            "$defender clinks.",
        },
    },
    -- To remove?
    ["D"] = {
        icon = "D",
        name = "Dodge",
        desc = "Absorbs 0. If removed first, the Attack is averted.",
        kind = "skill",
        absorbs = 0,
        triggerFirst = function(info)
            info.stop = "$defender dodged!"
        end,
        triggerLast = nil,
        trigger = nil,
        flavorTexts = {
            "",
        },
    },
    ["M"] = {
        icon = "M",
        name = "Mana",
        desc = "Absorbs 0.",
        kind = "special",
        absorbs = 0,
        triggerFirst = nil,
        triggerLast = nil,
        trigger = function(info)
            InsertStatus(info.defender, "M")
        end,
        flavorTexts = {
            "",
        },
    },
    ["B"] = {
        icon = "B",
        name = "Burn",
        desc = "Absorbs 0. If removed fist, double the AP. If removed, +1 AP.",
        kind = "special",
        absorbs = 0,
        triggerFirst = function(info)
            info.ap = info.ap * 2
        end,
        triggerLast = nil,
        trigger = function(info)
            info.ap = info.ap + 1
        end,
        flavorTexts = {
            "$defender staggers from the intense pain!",
        },
    },
}

local ActionTable = {
    ["Maul"] = {
        name = "Maul",
        desc = "A bludgeoning Attack.",
        kind = "bump",
        triggerFirst = nil,
        trigger = nil,
        flavorTexts = {
            ["health"] = {
                "$attacker mauls $defender."
            },
            ["armor"] = {
                "$attacker mauls $defender."
            },
            ["skill"] = {
                "$attacker mauls $defender."
            },
            ["magic"] = {
                "$attacker mauls $defender."
            },
            ["default"] = {
                "$attacker mauls $defender."
            },
        },
    },
    -- To remove?
    ["Alert"] = {
        name = "Alert",
        desc = "A normal Attack. A punch, or jab.",
        triggerFirst = function(info)
            local num_dodge = CountStatusIcons(info.attacker, "D")
            for i = num_dodge, info.ap - 1 do
                InsertStatus(info.attacker, "D")
            end
            info.stop = "$attacker becomes alert."
        end,
        trigger = nil,
        flavorTexts = {},
    },
    ["Slashing"] = {
        name = "Slashing",
        desc = "A sharp, slashing Attack. (25% to automatically remove a health status)",
        triggerFirst = nil,
        trigger = function(info)
            if math.random(1, 100) <= 25 and info.status.kind == "health" then
                info.forceRemove = true
            end
        end,
        flavorTexts = {
            ["health"] = {
                "$attacker slashes $defender's skin!",
                "$attacker makes a snap at $defender."
            },
            ["armor"] = {
                "$attacker's strike glances off $defender's armor.",
            },
            ["skill"] = {
                "$attacker slashes $defender.",
                "$attacker makes a snap at $defender."
            },
            ["magic"] = {
                "$attacker slashes $defender.",
                "$attacker makes a snap at $defender."
            },
            ["default"] = {
                "$attacker slashes $defender.",
                "$attacker makes a snap at $defender."
            },
        },
    },
    ["Bashing"] = {
        name = "Bashing",
        desc = "A hard, thumping Attack. (25% to automatically remove an armor status)",
        triggerFirst = nil,
        trigger = function(info)
            if math.random(1, 100) <= 25 and info.status.kind == "armor" then
                info.forceRemove = true
            end
        end,
        flavorTexts = {
            ["health"] = {
                "$attacker bashes $defender."
            },
            ["armor"] = {
                "$attacker bashes $defender."
            },
            ["skill"] = {
                "$attacker bashes $defender."
            },
            ["magic"] = {
                "$attacker bashes $defender."
            },
            ["default"] = {
                "$attacker bashes $defender."
            },
        },
    },
    ["Fire"] = {
        name = "Fire",
        desc = "1M. A very hot Attack. (Adds burn statuses to the defender)",
        triggerFirst = function(info)
            if CountStatusIcons(info.attacker, "M") > 0 then
                RemoveStatus(info.attacker, "M")
                for i = 1, math.floor(info.ap / 2) do
                    InsertStatus(info.defender, "B")
                end
            else
                info.stop = "$attacker is out of mana."
            end
        end,
        trigger = function(info, msgs)
        end,
        flavorTexts = {
            ["health"] = {
                "The air around $attacker crackles then bursts into flames. $defender's skin is scorched!",
                "A beam of bright hot fire is channeled through $attacker's finger, striking $defender!"
            },
            ["armor"] = {
                "The air around $attacker crackles then bursts into flames. $defender's armor warps from the heat!"
            },
            ["skill"] = {
                "The air around $attacker crackles then bursts into flames. $defender is caught off guard!"
            },
            ["magic"] = {
                "The air around $attacker crackles then bursts into flames. $defender attempts to endure!"
            },
            ["default"] = {
                "The air around $attacker crackles then bursts into flames. $defender becomes ingulfed in flames!"
            },
        },
    },
}

-- To remove?
local BeingTable = {
    ["Golem"] = {
        name = "Golem",
        nick = "Golem",
        desc = "",
        kind = "golem",
        actions = {["Maul"] = 2},
        statuses = {"C", "C", "C", "C", "C"},
    },
}



--[[
Internal functions.
--]]
function PeekStatus(being)
    return StatusList[being.statuses[math.random(1, #being.statuses)]]
end

function RemoveStatus(being, st)
    for i, v in ipairs(being.statuses) do
        if v == st.icon then
            table.remove(being.statuses, i)
            return true
        end
    end
    return false
end

function InsertStatus(being, st)
    table.insert(being.statuses, st)
end

function CountStatusKinds(being, kind)
    local count = 0
    for i, v in ipairs(being.statuses) do
        if StatusList[v].kind == kind then
            count = count + 1
        end
    end
    return count
end

function CountStatusIcons(being, icon)
    local count = 0
    for i, v in ipairs(being.statuses) do
        if StatusList[v].icon == icon then
            count = count + 1
        end
    end
    return count
end



--[[
External functions.
--]]
function GenerateFlavorText(info)
    local str_table = {}
    local repl = {
        attacker = info.attacker.nick,
        defender = info.defender.nick,
        dmg = info.dmg,
    }
    local flavor = nil

    if info.stop and info.stop ~= "" then
        flavor = string.gsub(info.stop, "%$(%w+)", repl)
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

        if ActionTable[info.action.name].flavorTexts[StatusList[info.removed[1]].kind] then
            flavor = ActionTable[info.action.name].flavorTexts[StatusList[info.removed[1]].kind][math.random(1, #ActionTable[info.action.name].flavorTexts[StatusList[info.removed[1]].kind])]
        else
            flavor = ActionTable[info.action.name].flavorTexts["default"][math.random(1, #ActionTable[info.action.name].flavorTexts["default"])]
        end
        if flavor ~= "" then
            flavor = string.gsub(flavor, "%$(%w+)", repl)
            table.insert(str_table, flavor)
        end

        flavor = StatusList[max].flavorTexts[math.random(1, #StatusList[max].flavorTexts)]
        if flavor ~= "" then
            flavor = string.gsub(flavor, "%$(%w+)", repl)
            table.insert(str_table, flavor)
        end
    end

    flavor = string.gsub("$defender loses $dmg health!", "%$(%w+)", repl)
    table.insert(str_table, flavor)

    return table.concat(str_table, " ")
end

function HealthOf(being)
    return CountStatusKinds(being, "health")
end

function Attack(attacker, defender, action)
    local first = true
    local info = {
        attacker = attacker, -- Current attacker.
        defender = defender, -- Current defender.
        action = ActionTable[action], -- Current action.
        ap = attacker.actions[action], -- Current AP.

        stop = nil, -- This will be a string containing the reason for the stop.
        status = nil, -- This is the current status being removed. Maybe.
        forceRemove = false, -- Force removes the status without minusing AP.

        removed = {}, -- Removed status list.
        dmg = 0, -- Total damage (health).
    }

    while true do

        if info.stop then return info end
        if HealthOf(attacker) < 1 then return info end
        if HealthOf(defender) < 1 then return info end

        info.status = PeekStatus(defender)
        local count = CountStatusIcons(defender, info.status.icon)

        if first and info.action.triggerFirst then
            info.action.triggerFirst(info)
        elseif info.action.trigger then
            info.action.trigger(info)
        end
        if info.stop then return info end

        if info.RemoveStatus or info.ap >= info.status.absorbs then

            -- Not a forced remove, but an AP remove.
            if not info.forceRemove and info.ap >= info.status.absorbs then
                info.ap = info.ap - info.status.absorbs
            end
            RemoveStatus(defender, info.status)

            if first and info.status.triggerFirst then
                info.status.triggerFirst(info, msgs)
            elseif info.status.trigger then
                info.status.trigger(info, msgs)
            end

            if CountStatusIcons(defender, info.status.icon) < count then
                if info.status.kind == "health" then info.dmg = info.dmg + 1 end
                table.insert(info.removed, info.status.icon)
            end

        else
            break
        end

        first = false

        info.status = nil
        info.forceRemove = false
    end

    if #info.removed > 0 and info.removed[#info.removed].triggerLast then
        info.removed[#info.removed].triggerLast(info, msgs)
    end

    return info
end

function NewBeing(name, nick)
    local being = deepcopy(BeingTable[name] or {})
    being.nick = nick
    return being
end

return {
    StatusList = StatusList,
    ActionTable = ActionTable,
    BeingTable = BeingTable,
    GenerateFlavorText = GenerateFlavorText,
    HealthOf = HealthOf,
    Attack = Attack,
    NewBeing = NewBeing,
}
