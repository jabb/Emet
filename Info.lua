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
    layers[#layers][name] = {x=x, y=y}
end

local function SetField(name, value)
    layers[#layers][name].value = value
end

local function Render(self, x, y)
    for k,v in pairs(layers[#layers]) do

    end
end

Info = {
    SetDimensions = SetDimensions,
    PushLayer = PushLayer,
    PopLayer = PopLayer,
    Render = Render,
}

return Info
