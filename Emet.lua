#!/usr/bin/luajit2

local curses = require 'curses'
local Dungeon = require 'Dungeon'
local Golem = require 'Golem'
local Info = require 'Info'
local Messenger = require 'Messenger'
local Keybindings = require 'Keybindings'

local Emet

local function Initialize()
    math.randomseed(os.time())

    Emet.Dungeon = Dungeon(Emet.DungeonWidth, Emet.DungeonHeight)
    Emet.Dungeon:generate()
    for x,y,t in Emet.Dungeon:traverse() do t.visited = true end

    Emet.Player = Golem(Emet.Dungeon, Emet.Dungeon:randomVacancy())

    Emet.Info = Info
    Emet.Info.SetDimensions(Emet.InfoWidth, Emet.InfoHeight)
    Emet.Info.PushLayer()
    Emet.Info.NewField('Name', 1, 1, 32)
    Emet.Info.SetField('Name', Emet.Player:getName())
    Emet.Info.NewField('Health', 17, 1, 32)
    Emet.Info.SetField('Health', 'HHHHH')
    Emet.Info.NewField('Position', 1, 2, 32)
    Emet.Info.SetField('Position',
        string.format('@: (%d, %d)', Emet.Player:getX(), Emet.Player:getY()))

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
        Emet.Info.PushLayer()

        Emet.Info.NewField('Message', 20, 4)
        Emet.Info.SetField('Message', 'Are you sure?')

        Emet.Info.NewSelectableField('Yes', 20, 8)
        Emet.Info.NewSelectableField('No', 40, 8)
        Emet.Info.SetField('Yes', 'Yes')
        Emet.Info.SetField('No', 'No')

        local input = Emet.Info.GetInput(Emet.InfoX, Emet.InfoY, 'No')

        Emet.Messenger.Message('You chose: ' .. input)

        Emet.Info.PopLayer()
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
