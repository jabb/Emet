#!/usr/bin/luajit2

local function minPush(self, data)
    local i = #self._mem + 1
    while i > 1 and self._mem[math.floor(i / 2)] > data do
        self._mem[i] = self._mem[math.floor(i / 2)]
        i = math.floor(i / 2)
    end
    self._mem[i] = data
end

local function minPop(self)
    local i = 1
    local child
    local last = table.remove(self._mem)

    if #self._mem == 0 then return end

    while i * 2 <= #self._mem do
        child = i * 2

        if child ~= #self._mem and self._mem[child] > self._mem[child + 1] then
            child = child + 1
        end

        if last > self._mem[child] then
            self._mem[i] = self._mem[child]
        else
            break
        end

        i = child
    end

    self._mem[i] = last
end

local function maxPush(self, data)
    local i = #self._mem + 1
    while i > 1 and self._mem[math.floor(i / 2)] < data do
        self._mem[i] = self._mem[math.floor(i / 2)]
        i = math.floor(i / 2)
    end
    self._mem[i] = data
end

local function maxPop(self)
    local i = 1
    local child
    local last = table.remove(self._mem)

    if #self._mem == 0 then return end

    while i * 2 <= #self._mem do
        child = i * 2

        if child ~= #self._mem and self._mem[child] < self._mem[child + 1] then
            child = child + 1
        end

        if last < self._mem[child] then
            self._mem[i] = self._mem[child]
        else
            break
        end

        i = child
    end

    self._mem[i] = last
end

local function top(self)
    return self._mem[1]
end

local function size(self)
    return #self._mem
end

local function PQueue(minmax)
    minmax = minmax or 'Min'

    if minmax == 'Max' then
        return {
            _mem = {},

            push = maxPush,
            pop = maxPop,
            top = top,
            size = size,
        }
    else
        return {
            _mem = {},

            push = minPush,
            pop = minPop,
            top = top,
            size = size,
        }
    end
end

return PQueue
