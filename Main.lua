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

function table.deepcopy(object)
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

Emet.Messenger = View(Emet.MessengerX, Emet.MessengerY, Emet.MessengerWidth, Emet.MessengerHeight)
Emet.Stats = View(Emet.StatsX, Emet.StatsY, Emet.StatsWidth, Emet.StatsHeight)
Emet.Info = View(Emet.InfoX, Emet.InfoY, Emet.InfoWidth, Emet.InfoHeight)
Emet.Upgrades = View(Emet.UpgradesX, Emet.UpgradesY, Emet.UpgradesWidth, Emet.UpgradesHeight)

curses.start()

--[[

Main loop.

--]]

Emet.Stats:print(1, 1, '%s' % Emet.Player:getNick())
Emet.Stats:print(1, 2, '%s' % Emet.Player:getStatusString())
Emet.Stats:print(1, 3, 'Emet/Met: %d/%d' % {Emet.Player:getEmet(), Emet.Player:getMet()})
Emet.Stats:print(1, 4, 'DLVL: %s' % Emet.Dungeon:getDungeonLevel())
Emet.Stats:print(1, 5, 'Score: %s' % Emet.PlayerScore)

Emet.Stats:print(1, 7, 'Actions')
Emet.Stats:print(1, 8, '1: %s' % Emet.Player:getBump())
--Emet.Stats:print(1, 9, '2: %s' % Emet.Player:getSpecial())

Emet.Dungeon:render(Emet.DungeonX, Emet.DungeonY)
while true do
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
    elseif moved then
        local tile = Emet.Dungeon:tileAt(Emet.Player:getPosition())
        if tile.emet then
            Emet.Messenger:message('You picked up %d Emet!' % tile.emet)
            Emet.Player:modEmet(tile.emet)
            tile.emet = nil
        end

        if tile.met then
            Emet.Messenger:message('You picked up %d Met!' % tile.met)
            Emet.Player:modMet(tile.met)
            tile.met = nil
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
        local px, py = Emet.Player:getPosition()
        if Emet.Dungeon:tileAt(px, py).name == 'Pit' and Emet.Dungeon:golemAt(px, py) == Emet.Player then
            Emet.Enemies:clear()
            Emet.Dungeon:generate()
            Emet.Dungeon:incDungeonLevel()
            Emet.Enemies:generate()
            local px, py = Emet.Dungeon:getRandomVacancy()
            Emet.Player:moveTo(px, py)

            Emet.PlayerScore = Emet.PlayerScore + ((Emet.Dungeon:getDungeonLevel() - 1) * 100)
        end
    end

    if action == 'Cycle Bump' then
        Emet.Player:cycleBump()
    end

    if action == 'Upgrades' then
        Emet.Upgrades:clear()
        Emet.Upgrades:reset()
        Emet.Upgrades:message('Upgrades (To select press a-z; To quit press anything else)')
        Emet.Upgrades:message('Emet/Met: %d/%d' % {Emet.Player:getEmet(), Emet.Player:getMet()})
        Emet.Upgrades:message(('-'):rep(Emet.UpgradesWidth))
        Emet.Upgrades:message('a - Heal One (1 Emet; 0 Met)')
        Emet.Upgrades:message('b - Heal Max (%d Emet; 0 Met)' % (Emet.Dungeon:getDungeonLevel() + 1))
        Emet.Upgrades:message('')

        local selected = nil
        local start = string.byte('c')
        local upgrades = Emet.Player:getUpgrades()
        if upgrades then
            for i=1, #upgrades do
                Emet.Upgrades:message('%s - %s (%d Emet; %d Met)' % {
                    string.char(start + i - 1), upgrades[i].desc, upgrades[i].emet, upgrades[i].met
                })
            end

            local input = Emet.Upgrades:input()
            if input == 'a' and Emet.Player:getEmet() > 0 then
                Emet.Player:modEmet(-1)
                Emet.Player:heal(1)
                Emet.Messenger:message('You feel refreshed!')
                moved = true
            elseif input == 'b' and Emet.Player:getEmet() >= Emet.Dungeon:getDungeonLevel() + 1 then
                Emet.Player:modEmet(-(Emet.Dungeon:getDungeonLevel() + 1))
                Emet.Player:heal(Emet.Dungeon:getDungeonLevel() + 1)
                Emet.Messenger:message('You feel refreshed!')
                moved = true
            end

            for i=1, #upgrades do
                if input == string.char(start + i - 1) then
                    selected = i
                    break
                end
            end
        else
            local input = Emet.Upgrades:input()
            if input == 'a' and Emet.Player:getEmet() > 0 then
                Emet.Player:modEmet(-1)
                Emet.Player:heal(1)
                Emet.Messenger:message('You feel refreshed!')
                moved = true
            elseif input == 'b' and Emet.Player:getEmet() >= Emet.Dungeon:getDungeonLevel() + 1 then
                Emet.Player:modEmet(-(Emet.Dungeon:getDungeonLevel() + 1))
                Emet.Player:heal(Emet.Dungeon:getDungeonLevel() + 1)
                Emet.Messenger:message('You feel refreshed!')
                moved = true
            end
        end
        Emet.Upgrades:clear()
        Emet.Upgrades:reset()

        if selected and upgrades[selected].emet <= Emet.Player:getEmet() and upgrades[selected].met <= Emet.Player:getMet() then
            Emet.Player:doUpgrade(selected)
        elseif selected then
            Emet.Messenger:message('You do not have enough Emet/Met for that!')
        end
    end

    if moved then
        Emet.Enemies:update(Emet.Player)
        Emet.Dungeon:update()
    end

    Emet.Stats:clear()
    Emet.Stats:reset()
    Emet.Stats:print(1, 1, '%s' % Emet.Player:getNick())
    Emet.Stats:print(1, 2, '%s' % Emet.Player:getStatusString())
    Emet.Stats:print(1, 3, 'Emet/Met: %d/%d' % {Emet.Player:getEmet(), Emet.Player:getMet()})
    Emet.Stats:print(1, 4, 'DLVL: %s' % Emet.Dungeon:getDungeonLevel())
    Emet.Stats:print(1, 5, 'Score: %s' % Emet.PlayerScore)

    Emet.Stats:print(1, 7, 'Actions')
    Emet.Stats:print(1, 8, '1: %s' % Emet.Player:getBump())
    --Emet.Stats:print(1, 9, '2: %s' % Emet.Player:getSpecial())

    Emet.Info:clear()
    Emet.Info:reset()

    Emet.Dungeon:render(Emet.DungeonX, Emet.DungeonY)

    if Emet.Player:isDead() then
        curses.pick()
        Emet.Messenger:message('You died! Press "Q" to exit...')
        while Keybindings[curses.get_key()] ~= 'Quit' do end
        os.exit()
    end
end
