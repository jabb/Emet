#!/usr/bin/luajit2

local curses = require 'curses'
local Keybindings = require 'Keybindings'

local function printLine(self, x, y, str, ...)

end

local function message(self, str, ...)
    curses.move(self._x, self._yInc)
    curses.print(str, ...)
    self._yInc = self._yInc + 1
end

local function View(x, y, width, height)

    return {
        _x = x,
        _y = y,
        _width = width,
        _height = height,

        _yInc = 0,
    }
end

return View
