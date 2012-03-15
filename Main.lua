#!/usr/bin/luajit2

local curses = require 'curses'
local Dungeon = require 'Dungeon'
local Enemies = require 'Enemies'
local Info = require 'Info'
local Emet = require 'Emet'
local Golem = require 'Golem'
local Messenger = require 'Messenger'
local Keybindings = require 'Keybindings'

--[[

Utilities.

--]]

getmetatable("").__mod = function(a, b)
    if not b then
        return a
    elseif type(b) == "table" then
        return string.format(a, unpack(b))
    else
        return string.format(a, b)
    end
end

--[[

Initialization.

--]]

math.randomseed(os.time())

Emet.Dungeon = Dungeon(Emet.DungeonWidth, Emet.DungeonHeight)
Emet.Dungeon:generate()

Enemies.Generate(Emet.Dungeon)

Emet.Player = Golem(Emet.Dungeon, Emet.Dungeon:getRandomVacancy())
Emet.Player:setDisplay('@', curses.green, curses.underline)

Info.SetBounds(Emet.InfoX, Emet.InfoY, Emet.InfoWidth, Emet.InfoHeight)
Info.PushLayer()
Info.NewField('Name', 1, 1, 32)
Info.SetField('Name', Emet.Player:getName())
Info.NewField('Health', 1, 2, 32)
Info.SetField('Health', 'HHHHH')
Info.NewField('Position', 1, 3, 32)
Info.SetField('Position', '@: (%d, %d)' % {Emet.Player:getPosition()})

Messenger.SetBounds(Emet.MessengerX, Emet.MessengerY, Emet.MessengerWidth, Emet.MessengerHeight)

curses.start()

--[[

Pause for resize.

--]]

local w, h = curses.size()
while w ~= Emet.ConsoleWidth or h ~= Emet.ConsoleHeight do
    curses.move(0, 0)
    curses.pick()
    curses.print("Please resize to %dx%d.", Emet.ConsoleWidth, Emet.ConsoleHeight)
    curses.get_key()
    w, h = curses.size()
end

--[[

Main loop.

--]]

while true do
    Emet.Dungeon:render(Emet.DungeonX, Emet.DungeonY)
    Info.Render()
    Messenger.Update()
    Messenger.Render()

    local key = curses.get_key()
    local action = Keybindings[key]
    local moved, dx, dy = false, 0, 0
    if action == 'Move Up' then moved, dx, dy = true, 0, -1 end
    if action == 'Move Down' then moved, dx, dy = true, 0, 1 end
    if action == 'Move Left' then moved, dx, dy = true, -1, 0 end
    if action == 'Move Right' then moved, dx, dy = true, 1, 0 end
    if action == 'Move Up-left' then moved, dx, dy = true, -1, -1 end
    if action == 'Move Up-right' then moved, dx, dy = true, 1, -1 end
    if action == 'Move Down-left' then moved, dx, dy = true, -1, 1 end
    if action == 'Move Down-right' then moved, dx, dy = true, 1, 1 end

    if moved and not Emet.Player:moveBy(dx, dy) then
        if Emet.Player:bump(Emet.Player:getX() + dx, Emet.Player:getY() + dy) then
            Messenger.Message('You dealt 1 damage!')
        end
    end

    if action == 'Quit' then
        local answer = Info.AskYesNo(Emet.InfoX, Emet.InfoY, 'Are you sure?')
        if answer == 'Yes' then
            os.exit()
        end
    end
    if action == 'Activate' then
        local px, py = Emet.Player:getX(), Emet.Player:getY()
        if Emet.Dungeon:tileAt(px, py).name == 'Pit' and Emet.Dungeon:golemAt(px, py) == Emet.Player then
            Enemies.Clear(Emet.Dungeon)
            Emet.Dungeon:generate()
            Enemies.Generate(Emet.Dungeon)
            local px, py = Emet.Dungeon:getRandomVacancy()
            Emet.Player:moveTo(px, py)
        end
    end

    Info.SetField('Position', '@: (%d, %d)' % {Emet.Player:getPosition()})

    if moved then
        Enemies.Update(Emet.Dungeon, Emet.Player)
    end
end
