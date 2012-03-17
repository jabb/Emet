#!/usr/bin/luajit

local curses = require 'curses'

return {
    [string.byte('Q')] = 'Quit',

    [string.byte('k')] = 'Move Up',
    [string.byte('j')] = 'Move Down',
    [string.byte('h')] = 'Move Left',
    [string.byte('l')] = 'Move Right',

    [string.byte('y')] = 'Move Up-left',
    [string.byte('u')] = 'Move Up-right',
    [string.byte('b')] = 'Move Down-left',
    [string.byte('n')] = 'Move Down-right',

    [string.byte('.')] = 'Wait',

    [string.byte('1')] = 'Move Down-left',
    [string.byte('2')] = 'Move Down',
    [string.byte('3')] = 'Move Down-right',
    [string.byte('4')] = 'Move Left',
    [string.byte('6')] = 'Move Right',
    [string.byte('7')] = 'Move Up-left',
    [string.byte('8')] = 'Move Up',
    [string.byte('9')] = 'Move Up-right',
    [string.byte('5')] = 'Wait',

    [curses.key_up] = 'Move Up',
    [curses.key_down] = 'Move Down',
    [curses.key_left] = 'Move Left',
    [curses.key_right] = 'Move Right',

    [string.byte('\n')] = 'Activate',
    [string.byte(' ')] = 'Activate',

    [string.byte('a')] = 'CycleBump',
}
