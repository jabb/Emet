#!/usr/bin/luajit

local curses = require 'curses'
local Dungeon = require 'Dungeon'
local Enemies = require 'Enemies'
local Emet = require 'Emet'
local Golem = require 'Golem'
local Keybindings = require 'Keybindings'
local View = require 'View'

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

Emet.Enemies = Enemies()
Emet.Enemies:generate()

Emet.Player = Golem(Emet.Dungeon:getRandomVacancy())
Emet.Player:setDisplay('@', curses.green, curses.underline)

Emet.Info = View(Emet.InfoX, Emet.InfoY, Emet.InfoWidth, Emet.InfoHeight)
Emet.Messenger = View(Emet.MessengerX, Emet.MessengerY, Emet.MessengerWidth, Emet.MessengerHeight)

curses.start()

--[[

Main loop.

--]]

Emet.Info:print(1, 1, '%s' % Emet.Player:getName())
Emet.Info:print(1, 2, '@: (%d, %d)' % {Emet.Player:getPosition()})

while true do
    Emet.Dungeon:update()
    Emet.Dungeon:render(Emet.DungeonX, Emet.DungeonY)

    local key = curses.get_key()

    Emet.Messenger:clear()
    Emet.Messenger:reset()

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
            curses.pick()
            Emet.Messenger:message('You dealt 1 damage!')
        end
    end

    if action == 'Quit' then
        Emet.Messenger:clear()
        Emet.Messenger:reset()
        Emet.Messenger:print(1, 1, 'Are you sure? (y/N)')
        local answer = Emet.Messenger:input()
        if answer == 'y' or answer == 'Y' then
            os.exit()
        end
        Emet.Messenger:clear()
        Emet.Messenger:reset()
    end
    if action == 'Activate' then
        local px, py = Emet.Player:getX(), Emet.Player:getY()
        if Emet.Dungeon:tileAt(px, py).name == 'Pit' and Emet.Dungeon:golemAt(px, py) == Emet.Player then
            Emet.Enemies:clear()
            Emet.Dungeon:generate()
            Emet.Enemies:generate()
            local px, py = Emet.Dungeon:getRandomVacancy()
            Emet.Player:moveTo(px, py)
        end
    end

    Emet.Info:clear()
    Emet.Info:reset()
    Emet.Info:print(1, 1, '%s' % Emet.Player:getName())
    Emet.Info:print(1, 2, '@: (%d, %d)' % {Emet.Player:getPosition()})

    if moved then
        Emet.Enemies:update(Emet.Player)
    end
end
