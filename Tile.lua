#!/usr/bin/luajit2

local curses = require 'curses'

local TileTable = {
    Wall = {
        name = 'Wall',
        symbol = '#',
        color = curses.yellow,
        attributes = {curses.bold},
        blocksMovement = true,
        blocksSight = true,
    },
    Floor = {
        name = 'Floor',
        symbol = '.',
        shadowed = ' ',
        color = curses.blue,
        attributes = {},
        blocksMovement = false,
        blocksSight = false,
    },
    Pit = {
        name = 'Pit',
        symbol = '>',
        color = curses.magenta,
        attributes = {curses.bold},
        blocksMovement = false,
        blocksSight = false,
    },
}

local function render(self, x, y, shadowed)
    curses.move(x, y)
    if shadowed then
        curses.pick(curses.blue, curses.bold)
        curses.print(self.shadowed or self.symbol)
    else
        curses.pick(self.color, unpack(self.attributes))
        curses.print(self.symbol)
    end
end

local function Tile(tile)
    return {
        name = TileTable[tile].name,
        symbol = TileTable[tile].symbol,
        shadowed = TileTable[tile].shadowed,
        color = TileTable[tile].color,
        attributes = TileTable[tile].attributes,
        blocksMovement = TileTable[tile].blocksMovement,
        blocksSight = TileTable[tile].blocksSight,

        render = render,
    }
end

return Tile
