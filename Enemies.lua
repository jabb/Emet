#!/usr/bin/luajit2

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

local function Update()
    for i=#list, 1, -1 do
    end
end

Enemies = {
    Generate = Generate,
    Clear = Clear,
    Update = Update,
}

return Enemies
