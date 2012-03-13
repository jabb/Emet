#!/usr/bin/luajit2

local curses = require 'curses'

local function render(self, x, y)

end

local function Update()
    for i=#messages, 1, -1 do
        messages[i].age = messages[i].age + 1
        if messages[i].age > 20 then
            table.remove(messages, i)
        end
    end
end

local function Info(width, height)

end

return Info
