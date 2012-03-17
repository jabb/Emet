#!/usr/bin/luajit

local AStar = require 'AStar'
local curses = require 'curses'
local Emet = require 'Emet'
local Being = require 'Being'

local function attack(self, x, y, with)
    if Emet.Dungeon:tileAt(x, y).golem then
        local info = self._being:attack(Emet.Dungeon:tileAt(x, y).golem._being, with)
        curses.pick()
        Emet.Messenger:message(Emet.GenerateFlavorText(info))
        return true
    end
    return false
end

local function bump(self, x, y)
    return self:attack(x, y, self._selectedBump)
end

local function getEmet(self) return self._emet end
local function setEmet(self, to) self._emet = to end
local function modEmet(self, by) self:setEmet(self._emet + by) end

local function getMet(self) return self._met end
local function setMet(self, to) self._met = to end
local function modMet(self, by) self:setMet(self._met + by) end

local function getX(self) return self._x end
local function getY(self) return self._y end
local function getPosition(self) return self._x, self._y end

local function getNick(self) return self._being._nick end
local function setNick(self, nick) self._being._nick = nick end

local function getStatusString(self)
    return table.concat(self._being._statuses, '')
end

local function setDisplay(self, symbol, color, ...)
    self._symbol = symbol
    self._color = color or curses.red
    self._attributes = {...}
end

local function isDead(self) return self._being:isDead() end

local function getAction(self, action)
    return self._being._actions[action]
end

local function setAction(self, action, to)
    self._being._actions[action] = to
end

local function modAction(self, action, by)
    self:setAction(action, self:getAction(action) + by)
end

local function cycleBump(self)
    local bumps = {}
    for k,_ in pairs(self._being._actions) do
        if Emet.ActionTable[k] and Emet.ActionTable[k].kind == 'bump' then
            table.insert(bumps, k)
        end
    end

    if #bumps < 1 then return end

    local i = 1
    while true do
        local done = false
        if bumps[i] == self._selectedBump then
            done = true
        end

        i = i + 1
        if i > #bumps then
            i = 1
        end

        if done then
            self._selectedBump = bumps[i]
            Emet.Messenger:message('%s' % self:getBumpDesc())
            break
        end
    end
end

local function getBump(self)
    return self._selectedBump or ''
end

local function getBumpDesc(self)
    if self:getBump() ~= '' then
        return Emet.ActionTable[self:getBump()].desc or ''
    else
        return ''
    end
end

local function cycleSpecial(self)
    local specials = {}
    for k,_ in pairs(self._being._actions) do
        if Emet.ActionTable[k] and Emet.ActionTable[k].kind == 'special' then
            table.insert(specials, k)
        end
    end

    if #specials < 1 then return end

    local i = 1
    while true do
        local done = false
        if specials[i] == self._selectedSpecial then
            done = true
        end

        i = i + 1
        if i > #specials then
            i = 1
        end

        if done then
            self._selectedSpecial = specials[i]
            Emet.Messenger:message('%s' % self:getSpecialDesc())
            break
        end
    end
end

local function getSpecial(self)
    return self._selectedSpecial or ''
end

local function getSpecialDesc(self)
    if self:getSpecial() ~= '' then
        return Emet.ActionTable[self:getSpecial()].desc or ''
    else
        return ''
    end
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

local function moveTo(self, x, y)
    if not Emet.Dungeon:inBounds(x, y) or not Emet.Dungeon:canOccupy(x, y) then
        -- You can move onto yourself.
        if Emet.Dungeon:tileAt(x, y).golem ~= self then
            return false
        end
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
        -- You can move onto yourself.
        if Emet.Dungeon:tileAt(x, y).golem ~= self then
            return false
        end
    end
    return true
end

local function canMoveBy(self, dx, dy)
    return self:canMoveTo(self._x + dx, self._y + dy)
end

local function render(self, x, y)
    curses.move(x, y)
    curses.pick(self._color, unpack(self._attributes))
    curses.print(self._symbol)
end

local function Golem(x, y, name)
    local g = {
        _being = Being('Golem'),
        _selectedBump = 'Maul',
        _selectedAction = nil,
        _emet = 0,
        _met = 0,

        _symbol = '@',
        _color = curses.red,
        _attributes = {},
        _x = x,
        _y = y,

        _targetN = nil,
        _targetPath = nil,

        attack = attack,
        bump = bump,

        getEmet = getEmet,
        setEmet = setEmet,
        modEmet = modEmet,
        getMet = getMet,
        setMet = setMet,
        modMet = modMet,

        getX = getX,
        getY = getY,
        getPosition = getPosition,
        getNick = getNick,
        setNick = setNick,
        getStatusString = getStatusString,
        setDisplay = setDisplay,
        isDead = isDead,

        getAction = getAction,
        setAction = setAction,
        modAction = modAction,
        cycleBump = cycleBump,
        getBump = getBump,
        getBumpDesc = getBumpDesc,
        cycleSpecial = cycleSpecial,
        getSpecial = getSpecial,
        getSpecialDesc = getSpecialDesc,

        setTarget = setTarget,
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
