#!/usr/bin/luajit

local AStar = require 'AStar'
local curses = require 'curses'
local Emet = require 'Emet'
local Being = require 'Being'

local function attack(self, x, y, with)
    if Emet.Dungeon:tileAt(x, y).golem then
        local info = self._being:attack(Emet.Dungeon:tileAt(x, y).golem._being, with)
        curses.pick()
        Emet.Messenger:message(self._being.GenerateFlavorText(info))
        return true
    end
    return false
end

local function bump(self, x, y)
    return self:attack(x, y, self._selectedBump)
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

local function getNick(self)
    return self._being._nick
end

local function setNick(self, nick)
    self._being._nick = nick
end

local function getHealth(self)
    return self._being:healthOf()
end

local function getStatusString(self)
    return table.concat(self._being._statuses, '')
end

local function setDisplay(self, symbol, color, ...)
    self._symbol = symbol
    self._color = color or curses.red
    self._attributes = {...}
end

local function setTarget(self, x, y)
    self._targetPath = AStar(self._x, self._y, x, y,
        Emet.Dungeon._tiles,
        Emet.Dungeon:getWidth(), Emet.Dungeon:getHeight(),
        function(t)
            return t.blocksMovement
        end)
    self._targetN = 2
end

local function isDead(self)
    return self:getHealth() < 1
end

local function moveTo(self, x, y)
    if not Emet.Dungeon:inBounds(x, y) or not Emet.Dungeon:canOccupy(x, y) then
        return false
    end
    if Emet.Dungeon:tileAt(self._x, self._y).golem == self then
        Emet.Dungeon:tileAt(self._x, self._y).golem = nil
    end
    self._x = x
    self._y = y
    Emet.Dungeon:tileAt(self._x, self._y).golem = self
    return true
end

local function moveBy(self, dx, dy)
    return self:moveTo(self._x + dx, self._y + dy)
end

local function nextStep(self)
    if self._targetPath and self._targetPath[self._targetN] then
        local step = self._targetPath[self._targetN]
        return step.x, step.y
    end
end

local function doStep(self)
    if self._targetPath and self._targetPath[self._targetN] then
        local x, y = self:nextStep()
        if self:canMoveTo(x, y) then
            self:moveTo(x, y)
            self._targetN = self._targetN + 1
            return true
        end
    end
    return false
end

local function canMoveTo(self, x, y)
    if not Emet.Dungeon:inBounds(x, y) or not Emet.Dungeon:canOccupy(x, y) then
        return false
    end
    return true
end

local function canMoveBy(self, dx, dy)
    return self:cMoveTo(self._x + dx, self._y + dy)
end

local function render(self, x, y)
    curses.move(x, y)
    curses.pick(self._color, unpack(self._attributes))
    curses.print(self._symbol)
end

local function Golem(x, y, name)
    local g = {
        _name = name or 'Golem',
        _symbol = '@',
        _color = curses.red,
        _attributes = {},
        _being = Being('Golem'),
        _selectedBump = 'Maul',
        _selectedAction = nil,
        _x = x,
        _y = y,

        _targetN = nil,
        _targetPath = nil,

        attack = attack,
        bump = bump,
        getX = getX,
        getY = getY,
        getPosition = getPosition,
        getNick = getNick,
        setNick = setNick,
        getHealth = getHealth,
        getStatusString = getStatusString,
        setDisplay = setDisplay,
        setTarget = setTarget,
        isDead = isDead,
        moveTo = moveTo,
        moveBy = moveBy,
        nextStep = nextStep,
        doStep = doStep,
        canMoveTo = canMoveTo,
        canMoveBy = canMoveBy,
        render = render,
    }

    g:moveTo(x, y)

    return g
end

return Golem
