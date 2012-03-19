#!/usr/bin/luajit

local ffi = require 'ffi'
local ncurses = ffi.load 'ncursesw'

ffi.cdef [[

typedef unsigned int chtype;
typedef struct WINDOW WINDOW;

enum {
    A_NORMAL   = (1U - 1U),
    A_ATTRIBUTES    = ((~(1U - 1U)) << ((0) + 8)),
    A_CHARTEXT  = ((1U) << ((0) - 1U) + 8),
    A_COLOR     = ((((1U) << 8) - 1U) << ((0) + 8)),
    A_STANDOUT  = ((1U) << ((8) + 8)),
    A_UNDERLINE = ((1U) << ((9) + 8)),
    A_REVERSE   = ((1U) << ((10) + 8)),
    A_BLINK     = ((1U) << ((11) + 8)),
    A_DIM       = ((1U) << ((12) + 8)),
    A_BOLD      = ((1U) << ((13) + 8)),
    A_ALTCHARSET    = ((1U) << ((14) + 8)),
    A_INVIS     = ((1U) << ((15) + 8)),
    A_PROTECT   = ((1U) << ((16) + 8)),
    A_HORIZONTAL    = ((1U) << ((17) + 8)),
    A_LEFT      = ((1U) << ((18) + 8)),
    A_LOW       = ((1U) << ((19) + 8)),
    A_RIGHT     = ((1U) << ((20) + 8)),
    A_TOP       = ((1U) << ((21) + 8)),
    A_VERTICAL  = ((1U) << ((22) + 8)),
};

enum {
    COLOR_BLACK,
    COLOR_RED,
    COLOR_GREEN,
    COLOR_YELLOW,
    COLOR_BLUE,
    COLOR_MAGENTA,
    COLOR_CYAN,
    COLOR_WHITE,
};

enum {
    KEY_CODE_YES  = 0400,
    KEY_MIN   = 0401,
    KEY_BREAK = 0401,
    KEY_SRESET= 0530,
    KEY_RESET = 0531,
    KEY_DOWN  = 0402,
    KEY_UP    = 0403,
    KEY_LEFT  = 0404,
    KEY_RIGHT = 0405,
    KEY_HOME  = 0406,
    KEY_BACKSPACE = 0407,
    KEY_F0    = 0410,
    KEY_F1    = 0411,
    KEY_F2    = 0412,
    KEY_F3    = 0413,
    KEY_F4    = 0414,
    KEY_F5    = 0415,
    KEY_F6    = 0416,
    KEY_F7    = 0417,
    KEY_F8    = 0420,
    KEY_F9    = 0421,
    KEY_F10   = 0422,
    KEY_F11   = 0423,
    KEY_F12   = 0424,
    KEY_DL    = 0510,
    KEY_IL    = 0511,
    KEY_DC    = 0512,
    KEY_IC    = 0513,
    KEY_EIC   = 0514,
    KEY_CLEAR = 0515,
    KEY_EOS   = 0516,
    KEY_EOL   = 0517,
    KEY_SF    = 0520,
    KEY_SR    = 0521,
    KEY_NPAGE = 0522,
    KEY_PPAGE = 0523,
    KEY_STAB  = 0524,
    KEY_CTAB  = 0525,
    KEY_CATAB = 0526,
    KEY_ENTER = 0527,
    KEY_PRINT = 0532,
    KEY_LL    = 0533,
    KEY_A1    = 0534,
    KEY_A3    = 0535,
    KEY_B2    = 0536,
    KEY_C1    = 0537,
    KEY_C3    = 0540,
    KEY_BTAB  = 0541,
    KEY_BEG   = 0542,
    KEY_CANCEL= 0543,
    KEY_CLOSE = 0544,
    KEY_COMMAND= 0545,
    KEY_COPY  = 0546,
    KEY_CREATE= 0547,
    KEY_END   = 0550,
    KEY_EXIT  = 0551,
    KEY_FIND  = 0552,
    KEY_HELP  = 0553,
    KEY_MARK  = 0554,
    KEY_MESSAGE= 0555,
    KEY_MOVE  = 0556,
    KEY_NEXT  = 0557,
    KEY_OPEN  = 0560,
    KEY_OPTIONS= 0561,
    KEY_PREVIOUS  = 0562,
    KEY_REDO  = 0563,
    KEY_REFERENCE = 0564,
    KEY_REFRESH= 0565,
    KEY_REPLACE= 0566,
    KEY_RESTART= 0567,
    KEY_RESUME= 0570,
    KEY_SAVE  = 0571,
    KEY_SBEG  = 0572,
    KEY_SCANCEL= 0573,
    KEY_SCOMMAND  = 0574,
    KEY_SCOPY = 0575,
    KEY_SCREATE= 0576,
    KEY_SDC   = 0577,
    KEY_SDL   = 0600,
    KEY_SELECT= 0601,
    KEY_SEND  = 0602,
    KEY_SEOL  = 0603,
    KEY_SEXIT = 0604,
    KEY_SFIND = 0605,
    KEY_SHELP = 0606,
    KEY_SHOME = 0607,
    KEY_SIC   = 0610,
    KEY_SLEFT = 0611,
    KEY_SMESSAGE  = 0612,
    KEY_SMOVE = 0613,
    KEY_SNEXT = 0614,
    KEY_SOPTIONS  = 0615,
    KEY_SPREVIOUS = 0616,
    KEY_SPRINT= 0617,
    KEY_SREDO = 0620,
    KEY_SREPLACE  = 0621,
    KEY_SRIGHT= 0622,
    KEY_SRSUME= 0623,
    KEY_SSAVE = 0624,
    KEY_SSUSPEND  = 0625,
    KEY_SUNDO = 0626,
    KEY_SUSPEND = 0627,
    KEY_UNDO  = 0630,
    KEY_MOUSE = 0631,
    KEY_RESIZE= 0632,
    KEY_EVENT = 0633,
    KEY_MAX   = 0777,
};

extern chtype acs_map[];
extern int LINES;
extern int COLS;

WINDOW *initscr(void);
int endwin(void);

int addstr(const char *str);
int getch(void);
int getnstr(char *str, int n);

int cbreak(void);
int nocbreak(void);
int echo(void);
int noecho(void);
int keypad(WINDOW *win, bool bf);
void timeout(int delay);
int curs_set(int visibility);

int move(int y, int x);

int attroff(chtype attrs);
int attron(chtype attrs);

int erase(void);
int refresh(void);

int start_color(void);
int init_pair(short pair, short fg, short bg);
int COLOR_PAIR(int);

]]

do
    local exit_list = {}
    local exit = os.exit
    local gcwatch = newproxy(true)

    local function cleanup()
        for x=#exit_list, 1, -1 do
            exit_list[x]()
        end
        exit_list = {}
        gcwatch = nil
    end

    getmetatable(gcwatch).__gc = cleanup

    function os.exit(...)
        cleanup()
        exit(...)
    end

    function os.atexit(fn)
        table.insert(exit_list, fn)
    end
end

local function assert_type(x, t)
    if type(x) ~= t then
        error("expected '" .. t .. "' got '" .. type(x) .. "'", 3)
    end
end

local local_x, local_y = 0, 0

local function stop()
    ncurses.timeout(-1)
    ncurses.curs_set(1)
    ncurses.echo()
    ncurses.nocbreak()
    ncurses.endwin()
end

local function start()
    local scr = ncurses.initscr()
    ncurses.noecho()
    ncurses.curs_set(0)
    ncurses.keypad(scr, 1)
    ncurses.cbreak()

    ncurses.start_color()
    for i=1, 8 do
        ncurses.init_pair(i - 1, i - 1, ncurses.COLOR_BLACK)
    end

    os.atexit(stop)
end

local function get_key(timeout)
    timeout = timeout or -1
    assert_type(timeout, 'number')
    ncurses.timeout(timeout)
    local key = ncurses.getch()
    ncurses.timeout(-1)
    return key
end

local function move(x, y)
    assert_type(x, 'number')
    assert_type(y, 'number')
    ncurses.move(y - 1, x - 1)
    local_x, local_y = x, y
end

local function pick(color, ...)
    color = color or ncurses.COLOR_WHITE
    assert_type(color, 'number')

    ncurses.attroff(0xFFFFFFFF)
    ncurses.attron(ncurses.COLOR_PAIR(color))
    local attributes = {...}
    for i=1, #attributes do
        assert_type(attributes[i], 'number')
        ncurses.attron(attributes[i])
    end
end

local function print(str, ...)
    assert_type(str, 'string')
    ncurses.addstr(string.format(str, ...))
    move(local_x, local_y)
end

local function get_string(len)
    len = len or 80
    assert_type(len, 'number')

    ncurses.curs_set(1)
    ncurses.echo()

    local cstr = ffi.new("char[?]", len + 1)
    ncurses.getnstr(cstr, len)

    ncurses.noecho()
    ncurses.curs_set(0)
    local str = ffi.string(cstr, len)
    return string.sub(str, 1, string.find(str, '%z') - 1)
end

local function clear()
    ncurses.erase()
end

local function update()
    ncurses.update()
end

local function size()
    return ncurses.COLS, ncurses.LINES
end

return {
    start = start,
    stop = stop,
    get_key = get_key,
    move = move,
    pick = pick,
    print = print,
    get_string = get_string,
    clear = clear,
    update = update,
    size = size,

    black   = ncurses.COLOR_BLACK,
    red     = ncurses.COLOR_RED,
    green   = ncurses.COLOR_GREEN,
    yellow  = ncurses.COLOR_YELLOW,
    blue    = ncurses.COLOR_BLUE,
    magenta = ncurses.COLOR_MAGENTA,
    cyan    = ncurses.COLOR_CYAN,
    white   = ncurses.COLOR_WHITE,

    standout      = ncurses.A_STANDOUT,
    reverse       = ncurses.A_REVERSE,
    bold          = ncurses.A_BOLD,
    dim           = ncurses.A_DIM,
    blink         = ncurses.A_BLINK,
    underline     = ncurses.A_UNDERLINE,

    key_none      = -1,
    key_code_yes  = ncurses.KEY_CODE_YES,
    key_min       = ncurses.KEY_MIN,
    key_break     = ncurses.KEY_BREAK,
    key_sreset    = ncurses.KEY_SRESET,
    key_reset     = ncurses.KEY_RESET,
    key_down      = ncurses.KEY_DOWN,
    key_up        = ncurses.KEY_UP,
    key_left      = ncurses.KEY_LEFT,
    key_right     = ncurses.KEY_RIGHT,
    key_home      = ncurses.KEY_HOME,
    key_backspace = ncurses.KEY_BACKSPACE,
    key_f0        = ncurses.KEY_F0,
    key_f1        = ncurses.KEY_F1,
    key_f2        = ncurses.KEY_F2,
    key_f3        = ncurses.KEY_F3,
    key_f4        = ncurses.KEY_F4,
    key_f5        = ncurses.KEY_F5,
    key_f6        = ncurses.KEY_F6,
    key_f7        = ncurses.KEY_F7,
    key_f8        = ncurses.KEY_F8,
    key_f9        = ncurses.KEY_F9,
    key_f10       = ncurses.KEY_F10,
    key_f11       = ncurses.KEY_F11,
    key_f12       = ncurses.KEY_F12,
    key_dl        = ncurses.KEY_DL,
    key_il        = ncurses.KEY_IL,
    key_dc        = ncurses.KEY_DC,
    key_ic        = ncurses.KEY_IC,
    key_eic       = ncurses.KEY_EIC,
    key_clear     = ncurses.KEY_CLEAR,
    key_eos       = ncurses.KEY_EOS,
    key_eol       = ncurses.KEY_EOL,
    key_sf        = ncurses.KEY_SF,
    key_sr        = ncurses.KEY_SR,
    key_npage     = ncurses.KEY_NPAGE,
    key_ppage     = ncurses.KEY_PPAGE,
    key_stab      = ncurses.KEY_STAB,
    key_ctab      = ncurses.KEY_CTAB,
    key_catab     = ncurses.KEY_CATAB,
    key_enter     = ncurses.KEY_ENTER,
    key_print     = ncurses.KEY_PRINT,
    key_ll        = ncurses.KEY_LL,
    key_a1        = ncurses.KEY_A1,
    key_a3        = ncurses.KEY_A3,
    key_b2        = ncurses.KEY_B2,
    key_c1        = ncurses.KEY_C1,
    key_c3        = ncurses.KEY_C3,
    key_btab      = ncurses.KEY_BTAB,
    key_beg       = ncurses.KEY_BEG,
    key_cancel    = ncurses.KEY_CANCEL,
    key_close     = ncurses.KEY_CLOSE,
    key_command   = ncurses.KEY_COMMAND,
    key_copy      = ncurses.KEY_COPY,
    key_create    = ncurses.KEY_CREATE,
    key_end       = ncurses.KEY_END,
    key_exit      = ncurses.KEY_EXIT,
    key_find      = ncurses.KEY_FIND,
    key_help      = ncurses.KEY_HELP,
    key_mark      = ncurses.KEY_MARK,
    key_message   = ncurses.KEY_MESSAGE,
    key_move      = ncurses.KEY_MOVE,
    key_next      = ncurses.KEY_NEXT,
    key_open      = ncurses.KEY_OPEN,
    key_options   = ncurses.KEY_OPTIONS,
    key_previous  = ncurses.KEY_PREVIOUS,
    key_redo      = ncurses.KEY_REDO,
    key_reference = ncurses.KEY_REFERENCE,
    key_refresh   = ncurses.KEY_REFRESH,
    key_replace   = ncurses.KEY_REPLACE,
    key_restart   = ncurses.KEY_RESTART,
    key_resume    = ncurses.KEY_RESUME,
    key_save      = ncurses.KEY_SAVE,
    key_sbeg      = ncurses.KEY_SBEG,
    key_scancel   = ncurses.KEY_SCANCEL,
    key_scommand  = ncurses.KEY_SCOMMAND,
    key_scopy     = ncurses.KEY_SCOPY,
    key_screate   = ncurses.KEY_SCREATE,
    key_sdc       = ncurses.KEY_SDC,
    key_sdl       = ncurses.KEY_SDL,
    key_select    = ncurses.KEY_SELECT,
    key_send      = ncurses.KEY_SEND,
    key_seol      = ncurses.KEY_SEOL,
    key_sexit     = ncurses.KEY_SEXIT,
    key_sfind     = ncurses.KEY_SFIND,
    key_shelp     = ncurses.KEY_SHELP,
    key_shome     = ncurses.KEY_SHOME,
    key_sic       = ncurses.KEY_SIC,
    key_sleft     = ncurses.KEY_SLEFT,
    key_smessage  = ncurses.KEY_SMESSAGE,
    key_smove     = ncurses.KEY_SMOVE,
    key_snext     = ncurses.KEY_SNEXT,
    key_soptions  = ncurses.KEY_SOPTIONS,
    key_sprevious = ncurses.KEY_SPREVIOUS,
    key_sprint    = ncurses.KEY_SPRINT,
    key_sredo     = ncurses.KEY_SREDO,
    key_sreplace  = ncurses.KEY_SREPLACE,
    key_sright    = ncurses.KEY_SRIGHT,
    key_srsume    = ncurses.KEY_SRSUME,
    key_ssave     = ncurses.KEY_SSAVE,
    key_ssuspend  = ncurses.KEY_SSUSPEND,
    key_sundo     = ncurses.KEY_SUNDO,
    key_suspend   = ncurses.KEY_SUSPEND,
    key_undo      = ncurses.KEY_UNDO,
    key_mouse     = ncurses.KEY_MOUSE,
    key_resize    = ncurses.KEY_RESIZE,
    key_event     = ncurses.KEY_EVENT,
    key_max       = ncurses.KEY_MAX,
}
