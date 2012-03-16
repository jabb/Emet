#!/usr/bin/luajit

local PQueue = require 'PQueue'

local function AStarNodeLE(a, b)
    return (a.g + a.h) <= (b.g + b.h)
end

local function AStarNodeLT(a, b)
    return a <= b and not (a >= b)
end

local function AStarNodeEQ(a, b)
    return a <= b and a >= b
end

local function AStarNode(t)
    local n = {
        parent = t.parent or nil,
        closed = t.closed or false,
        x = t.x or nil,
        y = t.y or nil,
        g = t.g or 0,
        h = t.h or 0,
    }
    setmetatable(n, {})
    getmetatable(n).__le = AStarNodeLE
    getmetatable(n).__lt = AStarNodeLT
    getmetatable(n).__eq = AStarNodeEQ
    return n
end

local function Heuristic(x0, y0, x1, y1)
    local dx = math.abs(x0 - x1)
    local dy = math.abs(y0 - y1)
    local diag = math.min(dx, dy)
    local straight = dx + dy
    return diag + (straight - 2 * diag)
end

local function AStar(x0, y0, x1, y1, map, width, height, isBlocked)
    isBlocked = isBlocked or function(t)
        return t
    end

    local dirs = {
        {-1,  0, 10}, { 0, -1, 10}, { 0,  1, 10}, { 1,  0, 10},
        {-1, -1, 14}, {-1,  1, 14}, { 1, -1, 14}, { 1,  1, 14},
    }

    local open = PQueue('Min')
    function open:has(data)
        for i=1, #self._mem do
            if self._mem[i] == data then
                return true
            end
        end
        return false
    end

    local nodes = {}

    nodes[y0] = nodes[y0] or {}
    nodes[y0][x0] = AStarNode{x=x0, y=y0}

    open:push(nodes[y0][x0])

    while open:size() > 0 do
        local lowest = open:top()
        open:pop()
        lowest.closed = true

        if lowest.x == x1 and lowest.y == y1 then break end

        for i=1, #dirs do
            local nx = lowest.x + dirs[i][1]
            local ny = lowest.y + dirs[i][2]
            nodes[ny] = nodes[ny] or {}
            nodes[ny][nx] = nodes[ny][nx] or AStarNode {x=nx, y=ny}
            local neighbor = nodes[ny][nx]
            if nx >= 1 and nx <= width and ny >= 1 and ny <= height and
               not isBlocked(map[ny][nx]) and neighbor and
               not neighbor.closed then
                if not open:has(neighbor) then
                    neighbor.g = lowest.g + dirs[i][3]
                    neighbor.h = Heuristic(nx, ny, x1, y1)
                    open:push(neighbor)
                    neighbor.parent = lowest
                elseif lowest.g + dirs[i][3] < neighbor.g then
                    neighbor.g = lowest.g + dirs[i][3]
                    neighbor.parent = lowest
                end
            end
        end
    end

    local path = {}
    local head = nodes[y1] and nodes[y1][x1]

    if not head.parent then return path end

    while head do
        table.insert(path, {x=head.x, y=head.y})
        head = head.parent
    end

    for i=1, math.floor(#path / 2) do
        path[i], path[#path - i + 1] = path[#path - i + 1], path[i]
    end

    return path
end

return AStar
