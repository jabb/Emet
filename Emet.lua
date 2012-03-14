#!/usr/bin/luajit2

local curses = require 'curses'
local Dungeon = require 'Dungeon'
local Enemies = require 'Enemies'
local Golem = require 'Golem'
local Info = require 'Info'
local Messenger = require 'Messenger'
local Keybindings = require 'Keybindings'

local Emet

local function Initialize()
    math.randomseed(os.time())

    Emet.Dungeon = Dungeon(Emet.DungeonWidth, Emet.DungeonHeight)
    Emet.Dungeon:generate()

    Emet.Enemies = Enemies
    Emet.Enemies.Generate(Emet.Dungeon)

    Emet.Player = Golem(Emet.Dungeon, Emet.Dungeon:getRandomVacancy())
    Emet.Player:setDisplay('@', curses.green, curses.underline)

    Emet.Info = Info
    Emet.Info.SetDimensions(Emet.InfoWidth, Emet.InfoHeight)
    Emet.Info.PushLayer()
    Emet.Info.NewField('Name', 1, 1, 32)
    Emet.Info.SetField('Name', Emet.Player:getName())
    Emet.Info.NewField('Health', 17, 1, 32)
    Emet.Info.SetField('Health', 'HHHHH')
    Emet.Info.NewField('Position', 1, 2, 32)
    Emet.Info.SetField('Position',
        string.format('@: (%d, %d)', Emet.Player:getPosition()))

    Emet.Messenger = Messenger
    Emet.Messenger.SetDimensions(Emet.MessengerWidth, Emet.MessengerHeight)

    curses.start()
end

local function Process(key)
    local action = Keybindings[key]
    if action == 'Move Up' then Emet.Player:moveBy(0, -1) end
    if action == 'Move Down' then Emet.Player:moveBy(0, 1) end
    if action == 'Move Left' then Emet.Player:moveBy(-1, 0) end
    if action == 'Move Right' then Emet.Player:moveBy(1, 0) end
    if action == 'Move Up-left' then Emet.Player:moveBy(-1, -1) end
    if action == 'Move Up-right' then Emet.Player:moveBy(1, -1) end
    if action == 'Move Down-left' then Emet.Player:moveBy(-1, 1) end
    if action == 'Move Down-right' then Emet.Player:moveBy(1, 1) end
    if action == 'Quit' then os.exit() end
    if action == 'Activate' then
        local px, py = Emet.Player:getX(), Emet.Player:getY()
        if Emet.Dungeon:golemAt(px, py) == Emet.Player then
            Emet.Enemies.Clear(Emet.Dungeon)
            Emet.Dungeon:generate()
            Emet.Enemies.Generate(Emet.Dungeon)
            local px, py = Emet.Dungeon:randomVacancy()
            Emet.Player:moveTo(px, py)
        end
    end

    Emet.Info.SetField('Position',
        string.format('@: (%d, %d)', Emet.Player:getX(), Emet.Player:getY()))
end

local function MainLoop()
    while true do
        Emet.Dungeon:render(Emet.Player:getX(), Emet.Player:getY(),
            Emet.DungeonX, Emet.DungeonY)
        Emet.Info.Render(Emet.InfoX, Emet.InfoY)
        Emet.Messenger.Update()
        Emet.Messenger.Render(Emet.MessengerX, Emet.MessengerY)
        Emet.Process(curses.get_key())

        -- Enemy stuff!
        Emet.Enemies.Update(Emet.Dungeon, Emet.Player)
    end
end

Emet = {
    DungeonX = 1,
    DungeonY = 1,
    DungeonWidth = 64,
    DungeonHeight = 32,

    InfoX = 65,
    InfoY = 1,
    InfoWidth = 64,
    InfoHeight = 16,

    MessengerX = 65,
    MessengerY = 17,
    MessengerWidth = 64,
    MessengerHeight = 16,

    Initialize = Initialize,
    Process = Process,
    MainLoop = MainLoop,
}

return Emet
