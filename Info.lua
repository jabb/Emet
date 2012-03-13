#!/usr/bin/luajit2

local function render(self, x, y)
end

local function Info()
    return {

        render = render
    }
end

return Info
