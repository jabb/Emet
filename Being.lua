#!/usr/bin/luajit

local Emet = require 'Emet'

local ActionTable = Emet.ActionTable
local StatusTable = Emet.StatusTable

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
    if not by then
        self._statuses = deepcopy(self._max)
    else
        local missing = deepcopy(self._max)
        for i=1, #self._statuses do
            for j=1, #missing do
                if missing[j] == self._statuses[i] then
                    table.remove(missing, j)
                    break
                end
            end
        end

        for i=1, by do
            self:insertStatus(missing[i])
        end
    end
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
