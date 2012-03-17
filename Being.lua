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

local StatusTable = {
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
        desc = "A bludgeoning attack. Excellent against Clay.",
        kind = "bump",
        triggerFirst = nil,
        trigger = function(info)
            if math.random(1, 100) <= 25 and info.status.kind == "health" then
                info.forceRemove = true
            end
        end,
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
        desc = "",
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



local function GenerateFlavorText(info)
    local str_table = {}
    local repl = {
        attacker = info.attacker._nick,
        defender = info.defender._nick,
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

        if ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind] then
            flavor = ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind][math.random(1, #ActionTable[info.action.name].flavorTexts[StatusTable[info.removed[1]].kind])]
        else
            flavor = ActionTable[info.action.name].flavorTexts["default"][math.random(1, #ActionTable[info.action.name].flavorTexts["default"])]
        end
        if flavor ~= '' then
            flavor = string.gsub(flavor, "%$(%w+)", repl)
            table.insert(str_table, flavor)
        end

        flavor = StatusTable[max].flavorTexts[math.random(1, #StatusTable[max].flavorTexts)]
        if flavor ~= '' then
            flavor = string.gsub(flavor, "%$(%w+)", repl)
            table.insert(str_table, flavor)
        end
    end

    flavor = string.gsub("$defender loses $dmg health!", "%$(%w+)", repl)
    table.insert(str_table, flavor)

    return table.concat(str_table, " ")
end

local function GetAction(name)
    return ActionTable[name]
end

local function peekStatus(self)
    return self._statuses[math.random(1, #self._statuses)]
end

local function removeStatus(self, st)
    for i, v in ipairs(self._statuses) do
        if v == st then
            table.remove(self._statuses, i)
            return true
        end
    end
    return false
end

local function insertStatus(self, st)
    table.insert(self._statuses, st)
end

local function heal(self, by)
    self._statuses = deepcopy(self._max)
end

local function countStatusKinds(self, kind)
    local count = 0
    for i, v in ipairs(self._statuses) do
        if StatusTable[v].kind == kind then
            count = count + 1
        end
    end
    return count
end

local function countStatusIcons(self, icon)
    local count = 0
    for i, v in ipairs(self._statuses) do
        if StatusTable[v].icon == icon then
            count = count + 1
        end
    end
    return count
end

local function isDead(self)
    return self:countStatusKinds("health") < 1
end

local function attack(self, defender, action)
    local attacker = self

    local first = true
    local info = {
        attacker = attacker, -- Current attacker.
        defender = defender, -- Current defender.
        action = ActionTable[action], -- Current action.
        ap = attacker._actions[action], -- Current AP.

        stop = nil, -- This will be a string containing the reason for the stop.
        status = nil, -- This is the current status being removed. Maybe.
        forceRemove = false, -- Force removes the status without minusing AP.

        removed = {}, -- Removed status list.
        dmg = 0, -- Total damage (health).
    }

    while true do

        if info.stop then return info end
        if attacker:isDead() then return info end
        if defender:isDead() then return info end

        info.status = StatusTable[defender:peekStatus()]
        local count = defender:countStatusIcons(info.status.icon)

        if first and info.action.triggerFirst then
            info.action.triggerFirst(info)
        elseif info.action.trigger then
            info.action.trigger(info)
        end
        if info.stop then return info end

        if info.forceRemove or info.ap >= info.status.absorbs then

            -- Not a forced remove, but an AP remove.
            if not info.forceRemove and info.ap >= info.status.absorbs then
                info.ap = info.ap - info.status.absorbs
            end
            defender:removeStatus(info.status.icon)

            if first and info.status.triggerFirst then
                info.status.triggerFirst(info)
            elseif info.status.trigger then
                info.status.trigger(info)
            end

            if defender:countStatusIcons(info.status.icon) < count then
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
        info.removed[#info.removed].triggerLast(info)
    end

    return info
end

local function Being(nick, statuses)
    return  {
        _nick = nick,
        _desc = "",
        _kind = "golem",
        _actions = {["Maul"] = 1},
        _max = deepcopy(statuses) or {"C", "C", "C", "C", "C"},
        _statuses = statuses or {"C", "C", "C", "C", "C"},

        GenerateFlavorText = GenerateFlavorText,
        GetAction = GetAction,

        peekStatus = peekStatus,
        removeStatus = removeStatus,
        insertStatus = insertStatus,
        heal = heal,
        countStatusKinds = countStatusKinds,
        countStatusIcons = countStatusIcons,

        isDead = isDead,
        attack = attack,
    }
end

return Being
