#!/usr/bin/luajit

local Golem = require 'Golem'
local Emet = require 'Emet'

local Enemies

local list = {}

local function GenerateGolem()
    local g = Golem(Emet.Dungeon:getRandomVacancy())
    local base = Emet.HealthStatuses[math.random(#Emet.HealthStatuses)]
    local numStatuses = Emet.Dungeon:getDungeonLevel() + 1
    local action = Emet.BumpActions[math.random(#Emet.BumpActions)]

    if base == 'C' then g:setNick('Clay Golem') end
    if base == 'F' then g:setNick('Flesh Golem') end
    if base == 'S' then g:setNick('Stone Golem') end
    if base == 'M' then g:setNick('Metal Golem') end

    -- Add base statuses.
    local statuses = {}
    for i=1, math.floor(numStatuses / 2) do
        table.insert(statuses, base)
    end

    -- Add extra statuses.
    local statusTypes = {
        Emet.ArmorStatuses,
        Emet.SkillStatuses, Emet.SpecialStatuses,
        nil
    }
    local statusType = statusTypes[math.random(#statusTypes)]
    local status = statusType[math.random(#statusType)]

    for i=1, math.floor(numStatuses / 2) do
        table.insert(statuses, status)
    end

    g:setStatuses(statuses)
    g:setAction(action, math.ceil(Emet.Dungeon:getDungeonLevel() / 2))
    g:setBump(action)
    return g
end

local function generate(self, count)
    count = count or 5
    for i=1, count do
        table.insert(list, GenerateGolem())
    end
end

local function clear(self)
    for i=#list, 1, -1 do
        Emet.Dungeon:tileAt(list[i]:getPosition()).golem = nil
    end
    list = {}
end

local function update(self, player)
    for i=#list, 1, -1 do
        if list[i]:isDead() then
            Emet.Dungeon:tileAt(list[i]:getPosition()).golem = nil
            Emet.Messenger:message('You killed %s!' % list[i]:getNick())
            Emet.Dungeon:tileAt(list[i]:getPosition()).emet = math.random(0, 1)
            table.remove(list, i)
        else
            local gx, gy = list[i]:getPosition()
            local px, py = player:getPosition()
            if Emet.Dungeon:canSee(gx, gy, px, py, list[i]:getSight()) then
                list[i]:setTarget(px, py)
            end

            local x, y = list[i]:nextStep()
            if x and not list[i]:canMoveTo(x, y) then
                local golem = Emet.Dungeon:golemAt(x, y)
                if golem == player then
                    list[i]:bump(x, y)
                end
            elseif x then
                list[i]:doStep()
            end
        end
    end
end

local function Enemies()
    return {
        generate = generate,
        clear = clear,
        update = update,
    }
end

return Enemies
