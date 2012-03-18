#!/usr/bin/luajit

local CanSee = require 'CanSee'
local curses = require 'curses'
local Emet = require 'Emet'
local Tile = require 'Tile'

--[[

Dungeon Generation

--]]

-- This is used because I want a 1 think wall all the way around.
-- Only the generation code uses this code.
local function InBoundsSpecial(dun, x, y)
    return x >= 2 and x <= dun:getWidth() -1 and y >= 2 and y <= dun:getHeight() - 1
end

local function IsTowards(x, y, dx, dy, tox, toy)
    local tx, ty

    if x < tox then tx = 1
    elseif x > tox then tx = -1
    else tx = 0
    end

    if y < toy then ty = 1
    elseif y > toy then ty = -1
    else ty = 0
    end

    return dx == tx or dy == ty
end

local function WeightedTowards(x, y, tox, toy)
    local dirs = {
        { 0, -1},
        { 0,  1},
        {-1,  0},
        { 1,  0},
    }

    local r = math.random(#dirs)
    if IsTowards(x, y, dirs[r][1], dirs[r][2], tox, toy) then
        return dirs[r][1], dirs[r][2]
    end

    r = math.random(#dirs)
    return dirs[r][1], dirs[r][2]
end

local function RandomDig(d, cx, cy, x, y)
    cx, cy = cx or p.width / 2, cy or p.height / 2
    x, y = x or math.random(2, d:getWidth() - 1),
        y or math.random(2, d:getHeight() - 1)
    local dx, dy = 0, 0
    local marked = {}

    while true do
        if not InBoundsSpecial(d, x, y) then
            x = x - dx
            y = y - dy
        elseif d:tileAt(x, y).name == 'Floor' then
            break
        else
            table.insert(marked, {x=x, y=y})
        end
        dx, dy = WeightedTowards(x, y, cx, cy)
        x = x + dx
        y = y + dy
    end

    for i,v in ipairs(marked) do
        d:tileAt(v.x, v.y, Tile('Floor'))
        d:_insertVacany(x, y)
    end
end

local function RoomRandomDig(d, cx, cy, x, y)
    cx, cy = cx or p.width / 2, cy or p.height / 2
    x, y = x or math.random(2, d:getWidth() - 1),
        y or math.random(2, d:getHeight() - 1)
    local size = math.random(1, 5) -- Half-size. Size of the room is this*2+1
    local marked = {}

    for tx=x-size, x+size do
        for ty=y-size, y+size do
            if InBoundsSpecial(d, tx, ty) and d:tileAt(tx, ty).name == 'Wall' then
                table.insert(marked, {x=tx, y=ty})
            else
                return
            end
        end
    end

    RandomDig(d, cx, cy, x, y)

    for i,v in ipairs(marked) do
        d:tileAt(v.x, v.y, Tile('Floor'))
        d:_insertVacany(x, y)
    end
end

--[[

Dungeon

--]]

local function _insertVacany(self, x, y)
    if not self._vacant[x .. ',' .. y] then
        self._vacant[x .. ',' .. y] = true
        table.insert(self._vacant, {x=x, y=y})
    end
end

local function _removeVacancy(self, x, y)
    if self._vacant[x .. ',' .. y] then
        self._vacant[x .. ',' .. y] = nil
        for i,v in ipairs(self._vacant) do
            if v.x == x and v.y == y then
                table.remove(self._vacant, i)
                break
            end
        end
    end
end

local function _randomVacancy(self)
    if #self._vacant < 1 then return end
    local r = math.random(#self._vacant)
    return self._vacant[r].x, self._vacant[r].y
end

local function getWidth(self)
    return self._width
end

local function getHeight(self)
    return self._height
end

local function getRandomVacancy(self)
    while true do
        local x = math.random(self:getWidth())
        local y = math.random(self:getHeight())
        if self:canOccupy(x, y) then
            return x, y
        end
    end
end

local function tileAt(self, x, y, to)
    if to then
        self._tiles[y][x] = to
    end
    return self._tiles[y][x]
end

local function golemAt(self, x, y, to)
    if to then
        self:tileAt(x, y).golem = to
    end
    return self:tileAt(x, y).golem
end

local function inBounds(self, x, y)
    return x >= 1 and x <= self:getWidth() and y >= 1 and y <= self:getHeight()
end

local function canSee(self, sx, sy, ex, ey, range)
    range = range or 10
    return CanSee(sx, sy, ex, ey, range, self._tiles, function(t)
        return t.blocksSight
    end)
end

local function canOccupy(self, x, y)
    return not self:tileAt(x, y).blocksMovement and not self:golemAt(x, y)
end

local function incDungeonLevel(self)
    self._dlvl = self._dlvl + 1
end

local function getDungeonLevel(self)
    return self._dlvl
end

local function traverse(self)
    local y, x = 1, 1
    return function()
        local ry, rx = y, x
        y = y + 1
        if y > self:getHeight() then y = 1; x = x + 1 end

        if self:inBounds(rx, ry) then
            return rx, ry, self:tileAt(rx, ry)
        end
    end
end

local function generate(self)
    self._vacant = {}
    for x, y in self:traverse() do
        self:tileAt(x, y, Tile('Wall'))
    end

    local centerX = math.random(self:getWidth())
    local centerY = math.random(self:getHeight())

    for x=centerX-1, centerX+1 do
        for y=centerY-1, centerY+1 do
            if InBoundsSpecial(self, x, y) then
                self:tileAt(x, y, Tile('Floor'))
                self:_insertVacany(x, y)
            end
        end
    end

    local diggers = {
        RoomRandomDig,
        RoomRandomDig,
        RoomRandomDig,
        RoomRandomDig,
        RandomDig,
    }

    for i=1, 50 do
        local r = math.random(#diggers)
        diggers[r](self, self:_randomVacancy())
    end

    local x, y = self:_randomVacancy()
    self:tileAt(x, y, Tile('Pit'))

    self:tileAt(self:getRandomVacancy()).met = 1

    self._vacant = nil
end

local function update(self)
    if math.random() <= 0.01 then
        Emet.Enemies:generate(1)
    end

    if math.random() <= 0.01 then
        self:tileAt(self:getRandomVacancy()).emet = math.random(1, 5)
    end
end

local function render(self, x, y)
    x = x or 1
    y = y or 1
    local px, py = Emet.Player:getPosition()
    for dx,dy,t in self:traverse() do
        if self:canSee(px, py, dx, dy, Emet.Player:getSight()) then
            t.visited = true
            if t.golem then
                t.golem:render(dx + x - 1, dy + y - 1)
                if t.golem ~= Emet.Player and Emet.Info:linesLeft() >= 3 then
                    curses.pick()
                    Emet.Info:message(t.golem:getNick())
                    Emet.Info:message(t.golem:getStatusString())
                    Emet.Info:message('')
                end
            else
                t:render(dx + x - 1, dy + y - 1)
                if t.met and t.met > 0 then
                    curses.move(dx + x - 1, dy + y - 1)
                    curses.pick(curses.red, curses.bold)
                    curses.print('*')
                elseif t.emet and t.emet > 0 then
                    curses.move(dx + x - 1, dy + y - 1)
                    curses.pick(curses.green, curses.bold)
                    curses.print('*')
                end
            end
        elseif t.visited then
            t:render(dx + x - 1, dy + y - 1, true)
        else
            curses.move(dx + x - 1, dy + y - 1)
            curses.pick()
            curses.print(' ')
        end
    end
end

local function Dungeon(width, height)
    local tiles = {}

    for y=1, height do
        tiles[y] = {}
        for x=1, width do
            tiles[y][x] = nil
        end
    end

    return {
        _tiles = tiles,
        _width = width,
        _height = height,
        _dlvl = 1,

        -- These functions only help the generator's speed.
        _insertVacany = _insertVacany,
        _removeVacancy = _removeVacancy,
        _randomVacancy = _randomVacancy,

        getWidth = getWidth,
        getHeight = getHeight,
        getRandomVacancy = getRandomVacancy,

        tileAt = tileAt,
        golemAt = golemAt,

        inBounds = inBounds,
        canSee = canSee,
        canOccupy = canOccupy,

        incDungeonLevel = incDungeonLevel,
        getDungeonLevel = getDungeonLevel,

        traverse = traverse,
        generate = generate,
        update = update,
        render = render,
    }
end

return Dungeon
