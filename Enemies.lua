#!/usr/bin/luajit

local Golem = require 'Golem'
local Emet = require 'Emet'

local Enemies

local list = {}

local function generate(self, count)
    count = count or 5
    for i=1, count do
        table.insert(list, Golem(Emet.Dungeon:getRandomVacancy()))
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
            Emet.Dungeon:tileAt(list[i]:getPosition()).emet = math.random(0, 1)
            table.remove(list, i)
        else
            local gx, gy = list[i]:getPosition()
            local px, py = player:getPosition()
            if Emet.Dungeon:canSee(gx, gy, px, py) then
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
