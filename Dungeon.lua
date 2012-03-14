#!/usr/bin/luajit2

local CanSee = require 'CanSee'
local curses = require 'curses'
local Plane = require 'Plane'
local Tile = require 'Tile'

--[[

Dungeon Generation

--]]

-- This is used because I want a 1 think wall all the way around.
-- Only the generation code uses this code.
local function InBoundsSpecial(dun, x, y)
    return x >= 2 and x <= dun._plane.width -1 and
           y >= 2 and y <= dun._plane.height - 1
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
    local size = math.random(1, 3) -- Half-size. Size of the room is this*2+1
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

local function tileAt(self, x, y, to)
    return self._plane:at(x, y, to)
end

local function golemAt(self, x, y, to)
    if to then
        self:tileAt(x, y).golem = to
    end
    return self:tileAt(x, y).golem
end

local function inBounds(self, x, y)
    return self._plane:inBounds(x, y)
end

local function traverse(self)
    return self._plane:traverse()
end

local function getWidth(self)
    return self._plane.width
end

local function getHeight(self)
    return self._plane.height
end

local function getRandomVacancy(self)
    while true do
        local x, y = math.random(self:getWidth()), math.random(self:getHeight())
        if self:canOccupy(x, y) then
            return x, y
        end
    end
end

local function generate(self)
    self._vacant = {}
    for x, y in self._plane:traverse() do
        self._plane:at(x, y, Tile('Wall'))
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

    for i=1, 100 do
        local r = math.random(#diggers)
        diggers[r](self, self:_randomVacancy())
    end

    local x, y = self:_randomVacancy()
    self:tileAt(x, y, Tile('Pit'))
end

local function canSee(self, sx, sy, ex, ey)
    return CanSee(sx, sy, ex, ey, 10, self._plane.elems, function(t)
        return t.blocksSight
    end)
end

local function canOccupy(self, x, y)
    return not self:tileAt(x, y).blocksMovement and not self:golemAt(x, y)
end

local function render(self, px, py, x, y)
    x = x or 1
    y = y or 1
    for dx,dy,t in self:traverse() do
        if self:canSee(px, py, dx, dy) then
            t.visited = true
            if t.golem then
                t.golem:render(dx + x - 1, dy + y - 1)
            else
                t:render(dx + x - 1, dy + y - 1)
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
    local plane = Plane(width, height)

    return {
        _plane = plane,
        _player = nil,

        _vacant = {},
        _insertVacany = _insertVacany,
        _removeVacancy = _removeVacancy,
        _randomVacancy = _randomVacancy,

        tileAt = tileAt,
        golemAt = golemAt,
        getWidth = getWidth,
        getHeight = getHeight,
        getRandomVacancy = getRandomVacancy,
        inBounds = inBounds,
        traverse = traverse,
        generate = generate,
        canSee = canSee,
        canOccupy = canOccupy,
        render = render,
    }
end

return Dungeon
