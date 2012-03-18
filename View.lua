#!/usr/bin/luajit

local curses = require 'curses'
local Keybindings = require 'Keybindings'

local function clear(self, line)
    if line then
        self:print(1, line, (' '):rep(self._width))
    else
        for i=1, self._height do
            self:print(1, i, (' '):rep(self._width))
        end
    end
end

local function reset(self)
    self._yInc = 1
end

local function linesLeft(self)
    return self._height - self._yInc
end

local function print(self, x, y, str, ...)
    curses.move(self._x + x - 1, self._y + y - 1)
    if #{...} > 0 then
        curses.print((str % {...}):sub(1, self._width))
    else
        curses.print(str:sub(1, self._width))
    end
end

local function message(self, str, ...)
    if self._yInc >= self._height then
        self:print(1, self._yInc, '--More--')
        self:input()
        self:clear()
        self:reset()
    end

    self:print(1, self._yInc, str, ...)
    self._yInc = self._yInc + 1
end

local function input(self)
    local key = curses.get_key()
    local success, res = pcall(string.char, key)
    if success then
        return res
    end
end

local function width(self) return self._width end
local function height(self) return self._height end

local function View(x, y, width, height)
    return {
        _x = x,
        _y = y,
        _width = width,
        _height = height,

        _yInc = 1,

        clear = clear,
        reset = reset,
        linesLeft = linesLeft,
        print = print,
        message = message,
        input = input,
    }
end

return View
