#!/usr/bin/luajit2

local function CanSee(x0, y0, x1, y1, vis, sight, isBlocked)
    isBlocked = isBlocked or function(t)
        return t
    end

    if math.sqrt((x0 - x1)^2 + (y0 - y1)^2) > vis then
        return false
    end

    local err, e2
    local dx = math.abs(x1 - x0)
    local dy = math.abs(y1 - y0)
    local sx = x0 < x1 and 1 or -1
    local sy = y0 < y1 and 1 or -1
    if dx > dy then err = math.floor(dx / 2) else err = math.ceil(-dy / 2) end
    local prevx, prevy = x0, y0
    local dist = 0

    while x0 ~= x1 or y0 ~= y1 do
        if isBlocked(sight[y0][x0]) or dist >= vis - 1 then return false end

        if (x0 - prevx) + (y0 - prevy) == -2 or
           (x0 - prevx) + (y0 - prevy) ==  2 or
           (x0 - prevx) + (y0 - prevy) ==  0 then
            dist = dist + 1.41
        else
            dist = dist + 1
        end

        prevx, prevy = x0, y0

        e2 = err
        if e2 > -dx then err = err - dy; x0 = x0 + sx end
        if e2 <  dy then err = err + dx; y0 = y0 + sy end
    end

    return true
end

return CanSee
