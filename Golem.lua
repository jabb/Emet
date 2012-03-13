#!/usr/bin/luajit2

local curses = require 'curses'
local Tokens = require 'Tokens'

local function attack(self, other, with)

end

local function getHealth(self)
    local health = 0
    for i,t in self._tokens:iterate() do
        if t.class == 'Health' then
            health = health + 1
        end
    end
    return health
end

local function isDead(self)
    return self:getHealth() < 1
end

local function moveTo(self, x, y)
    if not self._dungeon:inBounds(x, y) or not self._dungeon:canOccupy(x, y) then
        return false
    end
    self._dungeon:tileAt(self._x, self._y).golem = nil
    self._x = x
    self._y = y
    self._dungeon:tileAt(self._x, self._y).golem = self
    return true
end

local function moveBy(self, dx, dy)
    return self:moveTo(self._x + dx, self._y + dy)
end

local function render(self, x, y)
    curses.move(x, y)
    curses.pick(curses.red, curses.bold)
    curses.print('@')
end

local function Golem(dun, x, y)
    local g = {
        _tokens = Tokens('CCCCC'),
        _dungeon = dun,
        _x = x,
        _y = y,

        attack = attack,
        getHealth = getHealth,
        isDead = isDead,
        moveTo = moveTo,
        moveBy = moveBy,
        render = render,
    }

    g:moveTo(x, y)

    return g
end

return Golem
