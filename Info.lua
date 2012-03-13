#!/usr/bin/luajit2

local curses = require 'curses'

local Info

local width = 0
local height = 0
local layers = {}

local function SetDimensions(w, h)
    width = w
    height = h
end

local function PushLayer()
    table.insert(layers, {})
end

local function PopLayer()
    table.remove(layers)
end

local function NewField(name, x, y)
    layers[#layers][name] = {
        x = x, y = y,
        value = 'nil',
        color = curses.white,
        attributes = {},
    }
end

local function DeleteField(name)
    layers[#layers][name] = nil
end

local function SetField(name, value, color, ...)
    layers[#layers][name].value = value
    layers[#layers][name].color = color or curses.white
    layers[#layers][name].attributes = {...}
end

local function Render(x, y)
    if #layers < 1 then return end

    local spaces = string.rep(' ', width)

    for yy=y, y + height do
        curses.move(x, yy)
        curses.pick()
        curses.print(spaces)
    end

    for k,v in pairs(layers[#layers]) do
        curses.move(v.x + x - 1, v.y + y - 1)
        curses.pick(v.color, unpack(v.attributes))
        curses.print("%s", tostring(v.value))
    end
end

Info = {
    SetDimensions = SetDimensions,
    PushLayer = PushLayer,
    PopLayer = PopLayer,
    NewField = NewField,
    SetField = SetField,
    Render = Render,
}

return Info
