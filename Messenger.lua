#!/usr/bin/luajit2

local curses = require 'curses'

local width = 0
local height = 0
local messages = {}

local Messenger

local function SetDimensions(w, h)
    width = w
    height = h
end

local function Message(say, color, ...)
    say = say:sub(1, width)
    color = color or curses.white
    if #messages >= height then
        table.remove(messages, 1)
    end
    table.insert(messages, {say, color, {...}, age=1})
end

local function Update()
    for i=#messages, 1, -1 do
        messages[i].age = messages[i].age + 1
        if messages[i].age > 20 then
            table.remove(messages, i)
        end
    end
end

local function Render(x, y)
    local spaces = string.rep(' ', width)

    for yy=y, y + height do
        curses.move(x, yy)
        curses.pick()
        curses.print(spaces)
    end

    for i=1, #messages do
        curses.move(x, y + i - 1)
        curses.pick(messages[i][2], unpack(messages[i][3]))
        curses.print(messages[i][1])
    end
end

Messenger = {
    SetDimensions = SetDimensions,
    Message = Message,
    Update = Update,
    Render = Render,
}

return Messenger