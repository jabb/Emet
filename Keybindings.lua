#!/usr/bin/luajit2

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

    [curses.key_up] = 'Move Up',
    [curses.key_down] = 'Move Down',
    [curses.key_left] = 'Move Left',
    [curses.key_right] = 'Move Right',

    [string.byte(' ')] = 'Activate',
}
