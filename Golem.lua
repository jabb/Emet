#!/usr/bin/luajit2

local AStar = require 'AStar'
local curses = require 'curses'
local Messenger = require 'Messenger'
local Tokens = require 'Tokens'

local function attack(self, x, y, with)
    if self._dungeon:tileAt(x, y).golem then
        self._dungeon:tileAt(x, y).golem._tokens:remove()
        return true
    end
    return false
end

local function bump(self, x, y)
    return self:attack(x, y, self._bumps[self._selectedBump])
end

local function getX(self)
    return self._x
end

local function getY(self)
    return self._y
end

local function getPosition(self)
    return self._x, self._y
end

local function getName(self)
    return self._name
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

local function setDisplay(self, symbol, color, ...)
    self._symbol = symbol
    self._color = color or curses.red
    self._attributes = {...}
end

local function setTarget(self, x, y)
    self._targetPath = AStar(self._x, self._y, x, y,
        self._dungeon._tiles,
        self._dungeon:getWidth(), self._dungeon:getHeight(),
        function(t)
            return t.blocksMovement
        end)
    self._targetN = 2
end

local function moveToTarget(self)
    if self._targetPath and self._targetPath[self._targetN] then
        local step = self._targetPath[self._targetN]
        if self:moveTo(step.x, step.y) then
            self._targetN = self._targetN + 1
            return true
        end
    end
    return false
end

local function pathToTargetBlockedBy(self)
    if self._targetPath and self._targetPath[self._targetN] then
        local step = self._targetPath[self._targetN]
        local x, y = step.x, step.y
        if self._dungeon:inBounds(x, y) and self._dungeon:canOccupy(x, y) then
            return nil
        elseif self._dungeon:inBounds(x, y) and not self._dungeon:canOccupy(x, y) then
            return x, y, self._dungeon:tileAt(x, y)
        end
    end
    return nil
end

local function isDead(self)
    return self:getHealth() < 1
end

local function moveTo(self, x, y)
    if not self._dungeon:inBounds(x, y) or not self._dungeon:canOccupy(x, y) then
        return false
    end
    if self._dungeon:tileAt(self._x, self._y).golem == self then
        self._dungeon:tileAt(self._x, self._y).golem = nil
    end
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
    curses.pick(self._color, unpack(self._attributes))
    curses.print(self._symbol)
end

local function Golem(dun, x, y, name)
    local g = {
        _name = name or 'Golem',
        _symbol = '@',
        _color = curses.red,
        _attributes = {},
        _tokens = Tokens('CCCCC'),
        _selectedBump = 1,
        _bumps = {"Maul"},
        _selectedAction = 1,
        _actions = {},
        _dungeon = dun,
        _x = x,
        _y = y,

        _targetN = nil,
        _targetPath = nil,

        attack = attack,
        bump = bump,
        getX = getX,
        getY = getY,
        getPosition = getPosition,
        getName = getName,
        getHealth = getHealth,
        setDisplay = setDisplay,
        setTarget = setTarget,
        moveToTarget = moveToTarget,
        pathToTargetBlockedBy = pathToTargetBlockedBy,
        isDead = isDead,
        moveTo = moveTo,
        moveBy = moveBy,
        render = render,
    }

    g:moveTo(x, y)

    return g
end

return Golem
