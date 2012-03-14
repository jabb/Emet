#!/usr/bin/luajit2

local curses = require 'curses'
local Keybindings = require 'Keybindings'

local Info

local width = 0
local height = 0
local layers = {}
local selectables = {}

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

local function NewSelectableField(name, x, y, pos, len)
    pos = pos or #selectables + 1
    layers[#layers][name] = {
        x = x, y = y,
        pos = pos,
        selectable = true,
        length = len,
        value = 'nil',
        color = curses.white,
        attributes = {},
    }
    table.insert(selectables, pos, name)
end

local function NewField(name, x, y, len)
    layers[#layers][name] = {
        x = x, y = y,
        length = len,
        value = 'nil',
        color = curses.white,
        attributes = {},
    }
end

local function DeleteField(name)
    if layers[#layers][name].selectable then
        for i=1, #selectables do
            if selectables[i] == name then
                table.remove(selectables, i)
                break
            end
        end
    end
    layers[#layers][name] = nil
end

local function SetField(name, value, color, ...)
    if layers[#layers][name].length then
        layers[#layers][name].value = value:sub(1, layers[#layers][name].length)
    else
        layers[#layers][name].value = value
    end
    layers[#layers][name].color = color or curses.white
    layers[#layers][name].attributes = {...}
end

local function Render(x, y)
    if #layers < 1 then return end

    local spaces = string.rep(' ', width)

    for yy=y, y + height - 1 do
        curses.move(x, yy)
        curses.pick()
        curses.print(spaces)
    end

    for k,v in pairs(layers[#layers]) do
        curses.move(v.x + x - 1, v.y + y - 1)
        if v.selectable and v.selected then
            curses.pick(v.color, curses.reverse, unpack(v.attributes))
        else
            curses.pick(v.color, unpack(v.attributes))
        end
        curses.print("%s", tostring(v.value))
    end
end

local function GetInput(x, y, default, hook)
    if #selectables < 1 then
        return default
    end

    local input = default or selectables[1]
    local n

    for i=1, #selectables do
        if selectables[i] == input then
            n = i
            break
        end
    end

    layers[#layers][input].selected = true
    while true do
        Info.Render(x, y)
        local action = Keybindings[curses.get_key()]
        if action == 'Escape' then
            return default
        elseif action == 'Move Left' then
            layers[#layers][input].selected = false
            n = n - 1
            if n < 1 then
                n = #selectables
            end
            input = selectables[n]
            layers[#layers][input].selected = true
            if hook then hook('Left', input) end
        elseif action == 'Move Right' then
            layers[#layers][input].selected = false
            n = n + 1
            if n > #selectables then
                n = 1
            end
            input = selectables[n]
            layers[#layers][input].selected = true
            if hook then hook('Right', input) end
        elseif action == 'Activate' then
            return input
        elseif action == 'Quit' then
            return default
        end
    end
    return default
end

local function AskYesNo(x, y, prompt, default)
    default = default or 'No'
    PushLayer()
    NewField('Query', math.floor(width / 3), math.floor(height / 3))
    NewSelectableField('Yes', math.floor(width / 3), math.floor(height / 2))
    NewSelectableField('No', math.floor(width / 3) * 2, math.floor(height / 2))
    SetField('Query', prompt)
    SetField('Yes', 'Yes')
    SetField('No', 'No')
    local input = GetInput(x, y, default)
    PopLayer()
    return input
end

Info = {
    SetDimensions = SetDimensions,
    PushLayer = PushLayer,
    PopLayer = PopLayer,
    NewSelectableField = NewSelectableField,
    NewField = NewField,
    SetField = SetField,
    Render = Render,
    GetInput = GetInput,
    AskYesNo = AskYesNo,
}

return Info
