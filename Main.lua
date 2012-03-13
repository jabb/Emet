#!/usr/bin/luajit2

local curses = require 'curses'
local Dungeon = require 'Dungeon'
local Golem = require 'Golem'
local Messenger = require 'Messenger'
local Keybindings = require 'Keybindings'

math.randomseed(os.time())

Messenger.SetDimensions(64, 16)

local dun = Dungeon(64, 32)
dun:generate()

for x,y,t in dun:traverse() do t.visited = true end

local player = Golem(dun, dun:randomVacancy())

local function Process(key)
    local action = Keybindings[key]
    if action == 'Move Up' then player:moveBy(0, -1) end
    if action == 'Move Down' then player:moveBy(0, 1) end
    if action == 'Move Left' then player:moveBy(-1, 0) end
    if action == 'Move Right' then player:moveBy(1, 0) end
    if action == 'Move Up-left' then player:moveBy(-1, -1) end
    if action == 'Move Up-right' then player:moveBy(1, -1) end
    if action == 'Move Down-left' then player:moveBy(-1, 1) end
    if action == 'Move Down-right' then player:moveBy(1, 1) end
    if action == 'Quit' then os.exit() end
end

Messenger.Message(string.format('%d, %d', dun:getWidth(), dun:getHeight()))

curses.start()

while true do
    dun:render(player._x, player._y)
    Messenger.Render(65, 16)
    Messenger.Update()
    Process(curses.get_key())
end
