#!/usr/bin/luajit2

local Golem = require 'Golem'
local Messenger = require 'Messenger'

local Enemies

local list = {}

local function Generate(dungeon, count)
    count = count or 5
    for i=1, count do
        table.insert(list, Golem(dungeon, dungeon:getRandomVacancy()))
    end
end

local function Clear(dungeon)
    for i=#list, 1, -1 do
        dungeon:tileAt(list[i]:getPosition()).golem = nil
    end
    list = {}
end

local function Update(dungeon, player)
    for i=#list, 1, -1 do
        local gx, gy = list[i]:getPosition()
        local px, py = player:getPosition()
        if dungeon:canSee(gx, gy, px, py) then
            list[i]:setTarget(px, py)
        end

        if not list[i]:moveToTarget() then
            local x, y, tile = list[i]:pathToTargetBlockedBy()
            if tile and tile.golem == player then
                list[i]:bump(x, y)
            end
        end

        if list[i]:isDead() then
            table.remove(list, i)
        end
    end
end

Enemies = {
    Generate = Generate,
    Clear = Clear,
    Update = Update,
}

return Enemies
