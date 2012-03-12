#!/usr/bin/luajit2

local curses = require 'curses'
local Dungeon = require 'Dungeon'
local Keybindings = require 'Keybindings'

math.randomseed(os.time())

local dun = Dungeon(128, 32)
dun:generate()

for x,y,t in dun:traverse() do t.visited = true end

local px, py = dun:randomVacancy()

local function MovePlayer(dx, dy)
    if not dun:inBounds(px + dx, py + dy) or dun:tileAt(px + dx, py + dy).name == 'Wall' then
        return false
    end
    px = px + dx
    py = py + dy
    return true
end

local function Process(key)
    local action = Keybindings[key]
    if action == 'Move Up' then MovePlayer(0, -1) end
    if action == 'Move Down' then MovePlayer(0, 1) end
    if action == 'Move Left' then MovePlayer(-1, 0) end
    if action == 'Move Right' then MovePlayer(1, 0) end
    if action == 'Move Up-left' then MovePlayer(-1, -1) end
    if action == 'Move Up-right' then MovePlayer(1, -1) end
    if action == 'Move Down-left' then MovePlayer(-1, 1) end
    if action == 'Move Down-right' then MovePlayer(1, 1) end
    if action == 'Quit' then os.exit() end
end

curses.start()

while true do
    dun:render(px, py)

    curses.move(px, py); curses.pick(curses.red)
    curses.print('@')

    Process(curses.get_key())
end
