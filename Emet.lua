#!/usr/bin/luajit

local Emet

Emet = {
    Dungeon = nil,
    Enemies = nil,
    Player = nil,

    ConsoleWidth = 80,
    ConsoleHeight = 24,

    DungeonX = 1,
    DungeonY = 5,
    DungeonWidth = 50,
    DungeonHeight = 20,

    InfoX = 51,
    InfoY = 5,
    InfoWidth = 30,
    InfoHeight = 20,

    MessengerX = 1,
    MessengerY = 1,
    MessengerWidth = 80,
    MessengerHeight = 4,

    Messenger = nil,
}

return Emet
