#!/usr/bin/luajit2

local TokenTable = {
    C = {
        name = 'Clay',
        class = 'Health',
        absorbs = 1,
        onFirstRemoval = {'continue'},
        onRemoval = {'continue'},
    },
    F = {
        name = 'Flesh',
        class = 'Health',
        absorbs = 1,
        onFirstRemoval = {'continue'},
        onRemoval = {'continue'},
    },
    S = {
        name = 'Stone',
        class = 'Health',
        absorbs = 1,
        onFirstRemoval = {'continue'},
        onRemoval = {'continue'},
    },
    M = {
        name = 'Metal',
        class = 'Health',
        absorbs = 1,
        onFirstRemoval = {'continue'},
        onRemoval = {'continue'},
    },
}

local function select(self)
    local r = math.random(#self._tokens)
    return r, TokenTable[t]
end

local function remove(self)
    local r, t = self:select()
    table.remove(self._tokens, r)
    return t
end

local function insert(self, t)
    table.insert(self._tokens, t)
end

local function iterate(self)
    local i = 0
    return function()
        i = i + 1
        if i < #self._tokens then return i, TokenTable[self._tokens[i]] end
    end
end

local function toString(self)
    return table.concat(self._tokens, '')
end

local function Tokens(str)
    local master = {}
    local tokens = {}
    for i=1, string.len(str) do
        table.insert(master, str:sub(1, 1))
        table.insert(tokens, str:sub(1, 1))
    end

    return {
        _master = master,
        _tokens = tokens,

        select = select,
        remove = remove,
        insert = insert,
        iterate = iterate,
        toString = toString,
    }
end

return Tokens
