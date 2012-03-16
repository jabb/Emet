#!/usr/bin/luajit2

local curses = require 'curses'
local Keybindings = require 'Keybindings'

local function clear(self, line)
    if line then
        self:print(0, line, (' '):rep(self._width))
    else
        for i=1, self._height do
            self:print(1, i, (' '):rep(self._width))
        end
    end
end

local function reset(self)
    self._yInc = 1
end

local function print(self, x, y, str, ...)
    curses.move(self._x + x - 1, self._y + y - 1)
    curses.print((str % {...}):sub(1, self._width))
end

local function message(self, str, ...)
    if self._yInc > self._height then
        self:clear()
        self:reset()
    end

    self:print(1, self._yInc, str, ...)
    self._yInc = self._yInc + 1
end

local function input(self)
    local failed, res = pcall(string.char, curses.get_key)
    if not failed then
        return res
    end
end

local function View(x, y, width, height)
    return {
        _x = x,
        _y = y,
        _width = width,
        _height = height,

        _yInc = 1,

        clear = clear,
        reset = reset,
        print = print,
        message = message,
        input = input,
    }
end

return View
