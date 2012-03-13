#!/usr/bin/luajit2

local function at(self, x, y, to)
    if to then
        self.elems[y][x] = to
    end
    return self.elems[y][x]
end

local function inBounds(self, x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

local function traverse(self)
    local y, x = 1, 1
    return function()
        local ry, rx = y, x
        y = y + 1
        if y > self.height then y = 1; x = x + 1 end

        if self:inBounds(rx, ry) then
            return rx, ry, self.elems[ry][rx]
        end
    end
end

local function Plane(width, height)
    local elems = {}

    for y=1, height do
        elems[y] = {}
        for x=1, width do
            elems[y][x] = nil
        end
    end

    return {
        elems = elems,
        width = width,
        height = height,

        at = at,
        inBounds = inBounds,
        traverse = traverse,
    }
end

return Plane
