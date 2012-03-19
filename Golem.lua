#!/usr/bin/luajit

local AStar = require 'AStar'
local curses = require 'curses'
local Emet = require 'Emet'
local Being = require 'Being'

local Upgrades = {
    First = {
        {
            desc = 'Stay a Clay Golem.',
            emet = 0,
            met = 1,
            can = function(golem) return true end,
            apply = function(golem)
                Emet.Messenger:message('You are permanently a Clay Golem!')
            end
        },
        {
            desc = 'Turn into a Flesh Golem. (All C tokens become F tokens)',
            emet = 0,
            met = 1,
            can = function(golem) return true end,
            apply = function(golem)
                golem:setKind('Flesh')
                golem:setStatuses({'F', 'F', 'F', 'F', 'F'}, true)
                Emet.Messenger:message('You are permanently a Flesh Golem!')
            end
        },
        {
            desc = 'Turn into a Stone Golem. (All C tokens become S tokens)',
            emet = 0,
            met = 1,
            can = function(golem) return true end,
            apply = function(golem)
                golem:setKind('Stone')
                golem:setStatuses({'S', 'S', 'S', 'S', 'S'}, true)
                Emet.Messenger:message('You are permanently a Stone Golem!')
            end
        },
        {
            desc = 'Turn into a Metal Golem. (All C tokens become M tokens)',
            emet = 0,
            met = 1,
            can = function(golem) return true end,
            apply = function(golem)
                golem:setKind('Metal')
                golem:setStatuses({'M', 'M', 'M', 'M', 'M'}, true)
                Emet.Messenger:message('You are permanently a Metal Golem!')
            end
        },
    },
    Clay = {
        -- Tier 1
        {
            {
                desc = 'Baked clay. (+2 C Tokens)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:addStatuses({'C', 'C'}, true)
                    Emet.Messenger:message('Your clay hardens!')
                end
            },
            {
                desc = 'Wet clay. (Aquire the Rust action)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:setAction('Rust', 1)
                    Emet.Messenger:message('You arms start dripping!')
                end
            },
            {
                desc = 'Coarse clay. (Aquire the Slashing action)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:setAction('Slash', 1)
                    Emet.Messenger:message('Your arms transform into sharp blades!')
                end
            },
            {
                desc = 'Hard clay. (Aquire the Bludgeon action)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:setAction('Bludgeon', 1)
                    Emet.Messenger:message('Your arms mold into giant spiked spheres!')
                end
            },
        },
        -- Tier 2
        {
            {
                desc = 'Solid clay. (+4 C Tokens)',
                emet = 0,
                met = 2,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:addStatuses({'C', 'C', 'C', 'C'}, true)
                    Emet.Messenger:message('Your clay hardens!')
                end
            },
            {
                desc = 'Strong arms. (+1 to Maul, Rust, Slash and Bludgeon)',
                emet = 0,
                met = 2,
                can = function(golem) return true end,
                apply = function(golem)
                    if golem:getAction('Maul') then
                        golem:modAction('Maul', 1)
                    end
                    if golem:getAction('Rust') then
                        golem:modAction('Rust', 1)
                    end
                    if golem:getAction('Slash') then
                        golem:modAction('Slash', 1)
                    end
                    if golem:getAction('Bludgeon') then
                        golem:modAction('Bludgeon', 1)
                    end
                    Emet.Messenger:message('Your arms increase in size!')
                end
            },
        },
    },
    Flesh = {
        -- Tier 1
        {
            {
                desc = 'Tough skin. (+2 F Tokens)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:addStatuses({'F', 'F'}, true)
                    Emet.Messenger:message('Your skin hardens!')
                end
            },
            {
                desc = 'Oozing skin. (Aquire the Rust action)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:setAction('Rust', 1)
                    Emet.Messenger:message('You are dripping!')
                end
            },
        },
    },
    Stone = {
        -- Tier 1
        {
            {
                desc = 'Granite skin. (+2 S Tokens)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:addStatuses({'S', 'S'}, true)
                    Emet.Messenger:message('Your stone hardens!')
                end
            },
            {
                desc = 'Sharp rocks. (Aquire the Slashing action)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:setAction('Slash', 1)
                    Emet.Messenger:message('Your arms transform into sharp blades!')
                end
            },
        },
    },
    Metal = {
        -- Tier 1
        {
            {
                desc = 'Steel frame. (+2 M Tokens)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:addStatuses({'M', 'M'}, true)
                    Emet.Messenger:message('Your skin hardens!')
                end
            },
            {
                desc = 'Mace fists. (Aquire the Bludgeon action)',
                emet = 0,
                met = 1,
                can = function(golem) return true end,
                apply = function(golem)
                    golem:setAction('Bludgeon', 1)
                    Emet.Messenger:message('Your arms mold into giant spiked spheres!')
                end
            },
        },
    }
}

local function attack(self, x, y, with)
    if Emet.Dungeon:tileAt(x, y).golem then
        local info = self._being:attack(Emet.Dungeon:tileAt(x, y).golem._being, with)
        curses.pick()
        local tab = Emet.GenerateFlavorText(info)
        if string.len(table.concat(tab, ' ')) > Emet.MessengerWidth then
            for i=1, #tab do
                Emet.Messenger:message(tab[i])
            end
        else
            Emet.Messenger:message(table.concat(tab, ' '))
        end
        return true
    end
    return false
end

local function bump(self, x, y)
    return self:attack(x, y, self._selectedBump)
end

local function getEmet(self) return self._emet end
local function setEmet(self, to) self._emet = to end
local function modEmet(self, by) self:setEmet(self._emet + by) end

local function getMet(self) return self._met end
local function setMet(self, to) self._met = to end
local function modMet(self, by) self:setMet(self._met + by) end

local function getSight(self) return self._sight end
local function setSight(self, to) self._sight = to end
local function modSight(self, by) self:setSight(self._sight + by) end

local function getX(self) return self._x end
local function getY(self) return self._y end
local function getPosition(self) return self._x, self._y end

local function getNick(self) return self._being._nick end
local function setNick(self, nick) self._being._nick = nick end

local function getStatuses(self) return self._being._statuses end
local function setStatuses(self, to, perm)
    if perm then
        self._being._max = table.deepcopy(to)
    end
    self._being._statuses = to
end
local function addStatuses(self, st, perm)
    if perm then
        if type(st) == 'table' then
            for i=1, #st do
                table.insert(self._being._max, st[i])
            end
        elseif type(st) == 'string' then
            table.insert(self._being._max, st)
        end
    end

    if type(st) == 'table' then
        for i=1, #st do
            table.insert(self._being._statuses, st[i])
        end
    elseif type(st) == 'string' then
        table.insert(self._being._statuses, st)
    end
end
local function getMissingStatuses(self)
    local missing = table.deepcopy(self._being._max)
    for i=1, #self._being._statuses do
        for j=1, #missing do
            if missing[j] == self._being._statuses[i] then
                table.remove(missing, j)
                break
            end
        end
    end
    return missing
end
local function getMaxStatuses(self)
    return self._being._max
end

local function heal(self, by)
    by = by or 1
    self._being:heal(by)
end

local function getStatusString(self)
    return table.concat(self._being._statuses, '')
end

local function setDisplay(self, symbol, color, ...)
    self._symbol = symbol
    self._color = color or curses.red
    self._attributes = {...}
end

local function isDead(self) return self._being:isDead() end

local function getAction(self, action)
    return self._being._actions[action]
end

local function setAction(self, action, to)
    self._being._actions[action] = to
end

local function modAction(self, action, by)
    self:setAction(action, self:getAction(action) + by)
end

local function cycleBump(self)
    local bumps = {}
    for k,_ in pairs(self._being._actions) do
        if Emet.ActionTable[k] and Emet.ActionTable[k].kind == 'bump' then
            table.insert(bumps, k)
        end
    end

    if #bumps < 1 then return end

    local i = 1
    while true do
        local done = false
        if bumps[i] and bumps[i] == self._selectedBump then
            done = true
        end

        i = i + 1
        if i > #bumps then
            i = 1
        end

        if done then
            self._selectedBump = bumps[i]
            Emet.Messenger:message('%s' % self:getBumpDesc())
            break
        end
    end
end

local function getBump(self)
    return self._selectedBump or ''
end

local function setBump(self, to)
    self._selectedBump = to
end

local function getBumpDesc(self)
    if self:getBump() ~= '' then
        return Emet.ActionTable[self:getBump()].desc or ''
    else
        return ''
    end
end

local function cycleSpecial(self)
    local specials = {}
    for k,_ in pairs(self._being._actions) do
        if Emet.ActionTable[k] and Emet.ActionTable[k].kind == 'special' then
            table.insert(specials, k)
        end
    end

    if #specials < 1 then return end

    local i = 1
    while true do
        local done = false
        if specials[i] and specials[i] == self._selectedSpecial then
            done = true
        end

        i = i + 1
        if i > #specials then
            i = 1
        end

        if done then
            self._selectedSpecial = specials[i]
            Emet.Messenger:message('%s' % self:getSpecialDesc())
            break
        end
    end
end

local function getSpecial(self)
    return self._selectedSpecial or ''
end

local function setSpecial(self, to)
    self._selectedSpecial = to
end

local function getSpecialDesc(self)
    if self:getSpecial() ~= '' then
        return Emet.ActionTable[self:getSpecial()].desc or ''
    else
        return ''
    end
end

local function getKind(self) return self._kind end
local function setKind(self, to) self._kind = to end

local function getUpgradeLevel(self) return self._upgrade end
local function setUpgradeLevel(self, to) self._upgrade = to end
local function modUpgradeLevel(self, by) self:setUpgradeLevel(self._upgrade + by) end

local function getUpgrades(self)
    if self:getUpgradeLevel() == 0 then
        return Upgrades.First
    else
        return Upgrades[self:getKind()][self:getUpgradeLevel()]
    end
end

local function canUpgrade(self, num)
    return self:getUpgrades()[num].can(self)
end

local function doUpgrade(self, num)
    if self:canUpgrade(num) then
        self:getUpgrades()[num].apply(self)
        self:modUpgradeLevel(1)
    end
end

local function setTarget(self, x, y)
    self._targetPath = AStar(self._x, self._y, x, y,
        Emet.Dungeon._tiles,
        Emet.Dungeon:getWidth(), Emet.Dungeon:getHeight(),
        function(t)
            return t.blocksMovement
        end)
    self._targetN = 2
end

local function moveTo(self, x, y)
    if not Emet.Dungeon:inBounds(x, y) or not Emet.Dungeon:canOccupy(x, y) then
        -- You can move onto yourself.
        if Emet.Dungeon:tileAt(x, y).golem ~= self then
            return false
        end
    end
    if Emet.Dungeon:tileAt(self._x, self._y).golem == self then
        Emet.Dungeon:tileAt(self._x, self._y).golem = nil
    end
    self._x = x
    self._y = y
    Emet.Dungeon:tileAt(self._x, self._y).golem = self
    return true
end

local function moveBy(self, dx, dy)
    return self:moveTo(self._x + dx, self._y + dy)
end

local function nextStep(self)
    if self._targetPath and self._targetPath[self._targetN] then
        local step = self._targetPath[self._targetN]
        return step.x, step.y
    end
end

local function doStep(self)
    if self._targetPath and self._targetPath[self._targetN] then
        local x, y = self:nextStep()
        if self:canMoveTo(x, y) then
            self:moveTo(x, y)
            self._targetN = self._targetN + 1
            return true
        end
    end
    return false
end

local function canMoveTo(self, x, y)
    if not Emet.Dungeon:inBounds(x, y) or not Emet.Dungeon:canOccupy(x, y) then
        -- You can move onto yourself.
        if Emet.Dungeon:tileAt(x, y).golem ~= self then
            return false
        end
    end
    return true
end

local function canMoveBy(self, dx, dy)
    return self:canMoveTo(self._x + dx, self._y + dy)
end

local function render(self, x, y)
    curses.move(x, y)
    curses.pick(self._color, unpack(self._attributes))
    curses.print(self._symbol)
end

local function Golem(x, y, name)
    local g = {
        _being = Being('Golem'),
        _kind = 'Clay',
        _upgrade = 0,
        _selectedBump = 'Maul',
        _selectedAction = nil,
        _emet = 0,
        _met = 0,

        _symbol = '@',
        _color = curses.red,
        _attributes = {},
        _sight = 10,
        _x = x,
        _y = y,

        _targetN = nil,
        _targetPath = nil,

        attack = attack,
        bump = bump,

        getEmet = getEmet,
        setEmet = setEmet,
        modEmet = modEmet,
        getMet = getMet,
        setMet = setMet,
        modMet = modMet,
        getSight = getSight,
        setSight = setSight,
        modSight = modSight,

        getX = getX,
        getY = getY,
        getPosition = getPosition,
        getNick = getNick,
        setNick = setNick,
        getStatuses = getStatuses,
        setStatuses = setStatuses,
        addStatuses = addStatuses,
        getMissingStatuses = getMissingStatuses,
        getMaxStatuses = getMaxStatuses,
        heal = heal,
        getStatusString = getStatusString,
        setDisplay = setDisplay,
        isDead = isDead,

        getAction = getAction,
        setAction = setAction,
        modAction = modAction,
        cycleBump = cycleBump,
        getBump = getBump,
        setBump = setBump,
        getBumpDesc = getBumpDesc,
        cycleSpecial = cycleSpecial,
        getSpecial = getSpecial,
        setSpecial = setSpecial,
        getSpecialDesc = getSpecialDesc,

        getKind = getKind,
        setKind = setKind,
        getUpgradeLevel = getUpgradeLevel,
        setUpgradeLevel = setUpgradeLevel,
        modUpgradeLevel = modUpgradeLevel,
        getUpgrades = getUpgrades,
        canUpgrade = canUpgrade,
        doUpgrade = doUpgrade,

        setTarget = setTarget,
        moveTo = moveTo,
        moveBy = moveBy,
        nextStep = nextStep,
        doStep = doStep,
        canMoveTo = canMoveTo,
        canMoveBy = canMoveBy,

        render = render,
    }

    g:moveTo(x, y)

    return g
end

return Golem
