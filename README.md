# Emet

Emet's goal is to test a combat model based around "tokens." These tokens almost entirely encompass a fighter's attributes. They can be both health and skills and armor. A fighter does have the option of various attacks which effect, and are effected, by tokens.

In Emet you control a golem. This golem starts off as a standard clay golem, and can stay a clay golem if you so desire, but can change to three other types:

  * **Clay** - This is the default type. Has advantages against everything but everything has advantages against it.
  * **Flesh** - This type of golem specializes in attacks that ail the opponent. Flesh golems are also good against metal golems via rust.
  * **Stone** - This type of golem specializes in tokens that pull off tricks like dodging and countering. Stone golems are good against flesh golems.
  * **Metal** - The hardiest. This type of golem specializes in a lot of health tokens and strong, consistent attacks. Metal golems are good against stone golems.

The goal of the game (roughly) is to get the highest score before dying. Currently the only way to gain score is by descending deeper.

## Running

To run you will need LuaJIT beta 6 or above and ncurses. If you get an error about not finding ncursesw. Change line 4 in curses.lua from `local ncurses = ffi.load 'ncursesw'` to `local ncurses = ffi.load 'ncurses'`.

You can also play it through SSH, but the connection may be slow:

    ssh emet@71.94.2.193
    password: met

## Controls

By default these are the controls, but you can change them at anytime (knowing a bit of Lua would help) in Keybindings.lua:

    Q - Quit.

    k - Move up.
    j - Move Down.
    h - Move Left.
    l - Move Right.

    y - Move Up-left.
    u - Move Up-right.
    b - Move Down-left.
    n - Move Down-right.

    . - Wait.

    1 - Move down-left.
    2 - Move down.
    3 - Move down-right.
    4 - Move left.
    6 - Move right.
    7 - Move up-left.
    8 - Move up.
    9 - Move up-right.
    5 - Wait.

    up = Move up.
    down = Move down.
    left = Move left.
    right = Move right.

    enter = Activate.
    space - Activate.

    a - Cycle bump action.

    @ - Upgrades.

## Enemies

Enemies in Emet are other golems like yourself. They progressively get harder as you descend further down the dungeons. You can quickly identify the type of golem by it's color. Yellow is clay, red is flesh, magenta is stone and white is metal. You'll see a list of visible golems, as well as their tokens, on the bottom right panel when you play.

## Combat

Combat is revolved around tokens. The number of cool things that can be done with tokens is almost limitless. To start, an attack has an associated number to it, this number typically indicated the number of tokens that will be removed in the event of an attack. `Maul (2)`, for example will try to remove 2 tokens. When a token is removed, it is removed at random. A token has a few "triggers." A token can have a trigger for when it's the first token removed, one of the middle tokens, or the last token. The dodge token, for example, when removed first averts the entire attack, however it's one of the few tokens that don't defend if removed in the middle, so if it's not removed first, an attack can sweep through a lot of dodge tokens.

Current list of tokens:

  * **C (Clay)** - This token has no effects.
  * **F (Flesh)** - This token has no effects.
  * **S (Stone)** - This token has no effects.
  * **M (Metal)** - This token has no effects.
  * **D (Dodge)** - When removed first, the attack is averted. Blocks 0 attack.
  * **W (Weakness)** - When removed first, the attack strength is doubled.
  * **A (Acid)** - When removed (anytime), the attack strength is increased 50%.

## Emet/met and Upgrades

In Emet you can upgrade your golem, you do so by pressing the '@' key (by default). To upgrade you need emet or met (or both). There is only one met per level, and it's a red asterisk, but there are is a lot of emet, and occasionally an enemy will drop some. Met is special in that it's always necessary for permanent upgrades.

At first you will have to choose a path: Clay, flesh, stone or metal. But then you'll get choices for upgrades in your chosen path.