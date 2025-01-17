--[[
    Copyright 2024 swordcube

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

---@diagnostic disable: invisible

local max = math.max

local NoteHitEvent = require("funkin.backend.events.NoteHitEvent") --- @type funkin.backend.events.NoteHitEvent
local NoteMissEvent = require("funkin.backend.events.NoteMissEvent") --- @type funkin.backend.events.NoteMissEvent

local Scoring = require("funkin.gameplay.scoring.Scoring") --- @type funkin.gameplay.scoring.Scoring
local PlayerStats = require("funkin.gameplay.PlayerStats") --- @type funkin.gameplay.PlayerStats

local function noteSort(a, b)
    return a:getTime() < b:getTime()
end

---
--- @class funkin.gameplay.Player : chip.core.Actor
---
local Player = Actor:extend("Player", ...)

function Player:constructor(cpu, type)
    Player.super.constructor(self)

    ---
    --- @protected
    ---
    self._attachedStrumLines = {} --- @type table<funkin.gameplay.StrumLine>

    ---
    --- @protected
    ---
    self._pressed = {false, false, false, false} --- @type table<boolean>

    ---
    --- @protected
    --- @type table<funkin.backend.input.InputAction>
    ---
    self._inputActions = {
        Controls.list.NOTE_LEFT,
        Controls.list.NOTE_DOWN,
        Controls.list.NOTE_UP,
        Controls.list.NOTE_RIGHT
    }

    ---
    --- @protected
    ---
    self._cpu = cpu --- @type boolean

    ---
    --- @protected
    ---
    self._type = type or "opponent" --- @type "opponent"|"player"

    self.stats = PlayerStats:new() --- @type funkin.gameplay.PlayerStats

    -- TODO: connect these shits to gameplay scripts

    self.onNoteHit = Signal:new():type(NoteHitEvent) --- @type chip.utils.Signal
    self.onNoteHitPost = Signal:new():type(NoteHitEvent) --- @type chip.utils.Signal

    self.onNoteMiss = Signal:new():type(NoteMissEvent) --- @type chip.utils.Signal
    self.onNoteMissPost = Signal:new():type(NoteMissEvent) --- @type chip.utils.Signal

    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    if game then
        self.onNoteHit:connect(function(e) game:callOnScripts("onNoteHit", {e}) end)
        self.onNoteHitPost:connect(function(e) game:callOnScripts("onNoteHitPost", {e}) end)
        
        self.onNoteMiss:connect(function(e) game:callOnScripts("onNoteMiss", {e}) end)
        self.onNoteMissPost:connect(function(e) game:callOnScripts("onNoteMissPost", {e}) end)

        if game.playerStrumLine == self then
            self.onNoteHit:connect(function(e) game:callOnScripts("onPlayerNoteHit", {e}) end)
            self.onNoteHitPost:connect(function(e) game:callOnScripts("onPlayerNoteHitPost", {e}) end)

            self.onNoteMiss:connect(function(e) game:callOnScripts("onPlayerNoteMiss", {e}) end)
            self.onNoteMissPost:connect(function(e) game:callOnScripts("onPlayerNoteMissPost", {e}) end)
        
        elseif game.opponentStrumLine == self then
            self.onNoteHit:connect(function(e) game:callOnScripts("onOpponentNoteHit", {e}) end)
            self.onNoteHitPost:connect(function(e) game:callOnScripts("onOpponentNoteHitPost", {e}) end)

            self.onNoteMiss:connect(function(e) game:callOnScripts("onOpponentNoteMiss", {e}) end)
            self.onNoteMissPost:connect(function(e) game:callOnScripts("onOpponentNoteMissPost", {e}) end)
        end
    end
end

function Player:isCPU()
    return self._cpu
end

---
--- @param  cpu  boolean
---
function Player:setCPU(cpu)
    self._cpu = cpu
end

function Player:getType()
    return self._type
end

---
--- @param  type  "opponent"|"player"
---
function Player:setType(type)
    self._type = type
end

function Player:getAttachedStrumLines()
    return self._attachedStrumLines
end

---
--- @param  strumLines  table<funkin.gameplay.StrumLine>
---
function Player:attachStrumLines(strumLines)
    self._attachedStrumLines = strumLines
end

---
--- @param  note  funkin.gameplay.Note
---
function Player:missNote(note)
    --- @type funkin.backend.events.NoteMissEvent
    local event = NoteMissEvent:new(
        note, self, self:getType() == "player", 10, 0.0475 + math.min(note:getLength() * 0.001, 0.25),
        self:getType() == "player", self:getType() == "player"
    )
    self.onNoteMiss:emit(event)

    if event:isCancelled() then
        return
    end
    note:miss()

    local stats = self.stats
    if event:breaksCombo() then
        stats:resetCombo()
        stats:increaseMissCombo()
        stats:increaseMisses()
    end
    stats:increaseScore(-event:getScore())
    stats:increaseHealth(-event:getHealthLoss())

    local strumLine = note:getStrumLine() --- @type funkin.gameplay.StrumLine
    local holdCoverMembers = strumLine.holdCovers:getMembers() --- @type table<funkin.gameplay.HoldCover>
    
    local holdCover = holdCoverMembers[note:getLane() + 1] --- @type funkin.gameplay.HoldCover
    holdCover:kill()

    local characters = strumLine:getCharacters()
    for i = 1, #characters do
        local character = characters[i] --- @type funkin.gameplay.Character
        character:sing(Constants.NOTE_DIRECTIONS[note:getLane() + 1], true)
    end
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    if not game then
        return
    end
    if (event:showJudgement() or event:showCombo()) and not Options.comboStacking then
        game.comboPopups:killAllSprites()
    end
    if event:showJudgement() then
        game.comboPopups:showJudgement("miss", note:getSkin())
    end
    if event:showCombo() then
        game.comboPopups:showCombo(-self.stats.missCombo, note:getSkin(), true)
    end
    game:updateScoreText()
    self.onNoteMissPost:emit(event)
end

---
--- @param  note  funkin.gameplay.Note
---
function Player:hitNote(note)
    local songPos = note:getAttachedConductor():getTime()
    local judgement = Scoring.judgeNote(note, songPos)
    if self:isCPU() then
        judgement = Scoring.getJudgements()[1]
    end
    --- @type funkin.backend.events.NoteHitEvent
    local event = NoteHitEvent:new(
        note, self, Scoring.breaksCombo(judgement), Scoring.scoreNote(note, songPos),
        Scoring.getAccuracyScore(judgement), judgement, 0.023 * Scoring.getHealthGainMultiplier(judgement),
        self:getType() == "player", self:getType() == "player", self:getType() == "player" and Scoring.splashAllowed(judgement) and Options.noteSplashes
    )
    self.onNoteHit:emit(event)

    if event:isCancelled() then
        return
    end
    local stats = self.stats
    if event:breaksCombo() then
        stats:resetCombo()
        stats:increaseMissCombo()
        stats:increaseMisses()
    else
        stats:resetMissCombo()
        stats:increaseCombo()
    end
    stats:increaseScore(event:getScore())
    stats:increaseHealth(event:getHealthGain())

    stats:increaseTotalNotesHit()
    stats:increaseAccuracyScore(event:getAccuracyScore())

    note:hit()
    
    local strumLine = note:getStrumLine() --- @type funkin.gameplay.StrumLine
    if note:getLength() > 0.0 and Options.holdCovers then
        local lane = note:getLane()
        local holdCoverMembers = strumLine.holdCovers:getMembers() --- @type table<funkin.gameplay.HoldCover>
        
        local holdCover = holdCoverMembers[lane + 1] --- @type funkin.gameplay.HoldCover
        holdCover:setup(strumLine, lane, note:getSkin())
    end
    local characters = strumLine:getCharacters()
    for i = 1, #characters do
        local character = characters[i] --- @type funkin.gameplay.Character
        character:sing(Constants.NOTE_DIRECTIONS[note:getLane() + 1], false, note:getLength())
    end
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    if not game then
        return
    end
    if (event:showJudgement() or event:showCombo()) and not Options.comboStacking then
        game.comboPopups:killAllSprites()
    end
    if event:showJudgement() then
        game.comboPopups:showJudgement(event:getJudgement(), note:getSkin())
    end
    if event:showCombo() then
        game.comboPopups:showCombo(self.stats.combo, note:getSkin())
    end
    game:updateScoreText()

    if event:showNoteSplash() then
        local splashCount = strumLine.splashes:getLength()
        local splashMembers = strumLine.splashes:getMembers()

        local splash = splashMembers[strumLine._curSplash] --- @type funkin.gameplay.NoteSplash
        splash:setup(strumLine, note:getLane(), note:getSkin())
        strumLine._curSplash = math.wrap(strumLine._curSplash + 1, 1, splashCount)
    end
    self.onNoteHitPost:emit(event)
end

---
--- @param  strumLine  funkin.gameplay.StrumLine
---
function Player:processOpponent(strumLine)
    local notes = strumLine.notes --- @type chip.graphics.CanvasLayer
    local noteMembers = notes:getMembers() --- @type table<funkin.gameplay.Note>

    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    for i = 1, notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        if note:isExisting() and note:isActive() then
            local wasHit = note:wasHit()
            local wasMissed = note:wasMissed()

            local time = note:getTime()
            local length = note:getLength()

            local songPos = note:getAttachedConductor():getTime()
            local stepCrotchet = note:getAttachedConductor():getStepCrotchet()

            -- if the note is able to be hit, hit it
            if not wasHit and time < songPos then
                local receptor = receptors[note:getLane() + 1] --- @type funkin.gameplay.Receptor
                receptor:press(true, max(length - stepCrotchet, stepCrotchet), true)
                self:hitNote(note)

                local game = Gameplay.instance --- @type funkin.scenes.Gameplay
                if game then                    
                    game:updateScoreText()
                end
            end
            -- give score and health for sustains
            if wasHit and not wasMissed and length > 0 then
                local dt = Engine.deltaTime
                self.stats:increaseHealth(dt * 0.125)
                self.stats:increaseScore(dt * 250.0)

                local game = Gameplay.instance --- @type funkin.scenes.Gameplay
                if game then
                    game:updateScoreText()
                end
            end
            -- kill note if it was held fully
            if wasHit and not wasMissed and time < songPos - (length - stepCrotchet) then
                local holdCoverMembers = strumLine.holdCovers:getMembers() --- @type table<funkin.gameplay.HoldCover>
                
                local holdCover = holdCoverMembers[note:getLane() + 1] --- @type funkin.gameplay.HoldCover
                holdCover:kill()

                note:kill()
                note:getSustain():kill()
            end
        end
    end
end

---
--- @param  strumLine  funkin.gameplay.StrumLine
---
function Player:processPlayer(strumLine)
    local notes = strumLine.notes --- @type chip.graphics.CanvasLayer
    local noteMembers = notes:getMembers() --- @type table<funkin.gameplay.Note>

    local timeScale = Engine.timeScale
    for i = 1, notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        if note:isExisting() and note:isActive() then
            local wasHit = note:wasHit()
            local wasMissed = note:wasMissed()

            local time = note:getTime()
            local length = note:getLength()

            local songPos = note:getAttachedConductor():getTime()
            local stepCrotchet = note:getAttachedConductor():getStepCrotchet()

            -- if note is too late, miss it
            if note:isTooLate() and not wasHit and not wasMissed then
                self:missNote(note)
            end
            -- give score and health for sustains
            if wasHit and not wasMissed and length > 0 then
                local dt = Engine.deltaTime
                self.stats:increaseHealth(dt * 0.125)
                self.stats:increaseScore(dt * 250.0)

                local game = Gameplay.instance --- @type funkin.scenes.Gameplay
                if game then
                    game:updateScoreText()
                end
            end
            -- kill note if it was held fully
            if wasHit and not wasMissed and time < songPos - (length - stepCrotchet) then
                local holdCoverMembers = strumLine.holdCovers:getMembers() --- @type table<funkin.gameplay.HoldCover>
                
                local holdCover = holdCoverMembers[note:getLane() + 1] --- @type funkin.gameplay.HoldCover
                if holdCover:isExisting() then
                    holdCover:splurge()
                end
                note:kill()
                note:getSustain():kill()
            end
            -- kill note if it was missed and is off screen
            if wasMissed and time < songPos - ((320 / (strumLine:getScrollSpeed() / timeScale)) + length) then
                note:kill()
                note:getSustain():kill()
            end
        end
    end
end

function Player:update(dt)
    for i = 1, #self._attachedStrumLines do
        local strumLine = self._attachedStrumLines[i] --- @type funkin.gameplay.StrumLine
        if self:isCPU() then
            self:processOpponent(strumLine)
        else
            self:processPlayer(strumLine)
        end
    end
end

---
--- @param  event  chip.input.InputEvent
---
function Player:input(event)
    if self:isCPU() then
        return
    end
    local pressed = self._pressed --- @type table<boolean>
    local actions = self._inputActions --- @type table<funkin.backend.input.InputAction>
    for i = 1, #actions do
        local action = actions[i] --- @type funkin.backend.input.InputAction
        if event:isPressed() then
            if not pressed[i] and action:check(InputState.JUST_PRESSED) then
                for j = 1, #self._attachedStrumLines do
                    local strumLine = self._attachedStrumLines[j] --- @type funkin.gameplay.StrumLine
                    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    
                    local receptor = receptors[i] --- @type funkin.gameplay.Receptor
                    local availableNotes = table.filter(strumLine.notes:getMembers(), function(n)
                        return n:getLane() == i - 1 and n:isExisting() and n:isActive() and n:canBeHit() and not n:wasHit() and not n:wasMissed() and not n:isTooLate()
                    end)
                    table.sort(availableNotes, noteSort)
    
                    local canHitNote = #availableNotes > 0
                    if canHitNote then
                        local note = availableNotes[1] --- @type funkin.gameplay.Note
                        self:hitNote(note)
                        receptor:press(true, max(note:getLength() - note:getAttachedConductor():getStepCrotchet(), 200))
                    else
                        receptor:press(false)
                    end
                end
                pressed[i] = true
            end
        else
            if pressed[i] and action:check(InputState.JUST_RELEASED) then
                for j = 1, #self._attachedStrumLines do
                    local strumLine = self._attachedStrumLines[j] --- @type funkin.gameplay.StrumLine
                    local receptors = strumLine.receptors:getMembers() --- @type table<funkin.gameplay.Receptor>
    
                    local receptor = receptors[i] --- @type funkin.gameplay.Receptor
                    receptor:release()

                    local noteMembers = strumLine.notes:getMembers() --- @type table<funkin.gameplay.Note>
                    for k = 1, strumLine.notes:getLength() do
                        local note = noteMembers[k] --- @type funkin.gameplay.Note
                        if note:isExisting() and note:isActive() and note:getLane() == i - 1 and note:wasHit() and not note:wasMissed() and note:getTime() > note:getAttachedConductor():getTime() - (note:getLength() - 200) then
                            self:missNote(note)
                        end
                    end
                end
                pressed[i] = false
            end
        end
    end
    Player.super.input(self)
end

return Player
