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
    elseif type(b) == 'table' then
        return string.format(a, unpack(b))
    else
        return string.format(a, b)
    end
end

function string.wrap(str, limit, indent, indent1)
    indent = indent or ''
    indent1 = indent1 or indent
    limit = limit or 72
    local here = 1 - #indent1
    return indent1 .. str:gsub('(%s+)()(%S+)()',
        function(sp, st, word, fi)
            if fi - here > limit then
                here = st - #indent
            return '\n' .. indent .. word
            end
        end)
end

getmetatable('').__index.wrap = string.wrap

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
Emet.Player:setNick(os.getenv('USER') or string.match(os.tmpname(), '_(.*)'))

Emet.Info = View(Emet.InfoX, Emet.InfoY, Emet.InfoWidth, Emet.InfoHeight)
Emet.Messenger = View(Emet.MessengerX, Emet.MessengerY, Emet.MessengerWidth, Emet.MessengerHeight)

curses.start()

--[[

Main loop.

--]]

Emet.Info:print(1, 1, '%s' % Emet.Player:getNick())
Emet.Info:print(1, 2, '%s' % Emet.Player:getStatusString())
Emet.Info:print(1, 3, '(%d, %d)' % {Emet.Player:getPosition()})

Emet.Info:print(1, 5, 'Actions')
Emet.Info:print(1, 6, '1: %s' % Emet.Player:getBump())
Emet.Info:print(1, 7, '2: %s' % Emet.Player:getSpecial())

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
    if action == 'Wait' then moved = true end

    if moved and not Emet.Player:moveBy(dx, dy) then
        Emet.Player:bump(Emet.Player:getX() + dx, Emet.Player:getY() + dy)
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
        local px, py = Emet.Player:getPosition()
        if Emet.Dungeon:tileAt(px, py).name == 'Pit' and Emet.Dungeon:golemAt(px, py) == Emet.Player then
            Emet.Enemies:clear()
            Emet.Dungeon:generate()
            Emet.Enemies:generate()
            local px, py = Emet.Dungeon:getRandomVacancy()
            Emet.Player:moveTo(px, py)
        else
            Emet.Player._being:heal(1)
        end
    end

    if action == 'CycleBump' then
        Emet.Player:cycleBump()
    end

    if moved then
        Emet.Enemies:update(Emet.Player)
    end

    Emet.Info:clear()
    Emet.Info:reset()
    Emet.Info:print(1, 1, '%s' % Emet.Player:getNick())
    Emet.Info:print(1, 2, '%s' % Emet.Player:getStatusString())
    Emet.Info:print(1, 3, '(%d, %d)' % {Emet.Player:getPosition()})

    Emet.Info:print(1, 5, 'Actions')
    Emet.Info:print(1, 6, '1: %s' % Emet.Player:getBump())
    Emet.Info:print(1, 7, '2: %s' % Emet.Player:getSpecial())

    if Emet.Player:isDead() then
        curses.pick()
        Emet.Messenger:message('You died! Press "Q" to exit...')
        while Keybindings[curses.get_key()] ~= 'Quit' do end
        os.exit()
    end
end
