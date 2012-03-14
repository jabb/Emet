#!/usr/bin/luajit2

local AStar = require 'AStar'
local Golem = require 'Golem'

local Enemies

local list = {}

local function Generate(dungeon, count)
    count = count or 20
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
            local path = AStar(gx, gy, px, py, dungeon._plane.elems,
                dungeon:getWidth(), dungeon:getHeight(),
                function(t)
                    return t.blocksMovement
                end)

            list[i]:moveTo(path[2].x, path[2].y)
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
