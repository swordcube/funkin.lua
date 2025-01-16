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

local CancellableEvent = require("funkin.backend.events.CancellableEvent") --- @type funkin.backend.events.CancellableEvent

---
--- @class funkin.backend.events.NoteHitEvent : funkin.backend.events.CancellableEvent
---
local NoteHitEvent = CancellableEvent:extend("NoteHitEvent", ...)

function NoteHitEvent:constructor(note, player, breaksCombo, score, accuracyScore, judgement, healthGain, showJudgement, showCombo, showNoteSplash)
    NoteHitEvent.super.constructor(self)

    ---
    --- @protected
    ---
    self._note = note --- @type funkin.gameplay.Note

    ---
    --- @protected
    ---
    self._player = player --- @type funkin.gameplay.Player

    ---
    --- @protected
    ---
    self._breaksCombo = breaksCombo --- @type boolean

    ---
    --- @protected
    ---
    self._score = score --- @type number

    ---
    --- @protected
    ---
    self._accuracyScore = accuracyScore --- @type number

    ---
    --- @protected
    ---
    self._judgement = judgement --- @type string

    ---
    --- @protected
    ---
    self._healthGain = healthGain --- @type number

    ---
    --- @protected
    ---
    self._showJudgement = showJudgement --- @type boolean

    ---
    --- @protected
    ---
    self._showCombo = showCombo --- @type boolean

    ---
    --- @protected
    ---
    self._showNoteSplash = showNoteSplash --- @type boolean
end

function NoteHitEvent:getNote()
    return self._note
end

function NoteHitEvent:getPlayer()
    return self._player
end

function NoteHitEvent:getStrumLine()
    return self._note:getStrumLine()
end

---
--- @return funkin.gameplay.Receptor
---
function NoteHitEvent:getReceptor()
    local strumLine = self._note:getStrumLine() --- @type funkin.gameplay.StrumLine
    return strumLine.receptors:getMembers()[self._note:getLane() + 1]
end

function NoteHitEvent:getTime()
    return self._note:getTime()
end

function NoteHitEvent:getLane()
    return self._note:getLane()
end

function NoteHitEvent:getDirection()
    return self._note:getLane()
end

function NoteHitEvent:getNoteData()
    return self._note:getLane()
end

function NoteHitEvent:getLength()
    return self._note:getLength()
end

function NoteHitEvent:getSustainLength()
    return self._note:getLength()
end

function NoteHitEvent:getNoteType()
    return self._note:getType()
end

function NoteHitEvent:breaksCombo()
    return self._breaksCombo
end

function NoteHitEvent:getScore()
    return self._score
end

function NoteHitEvent:getAccuracyScore()
    return self._accuracyScore
end

function NoteHitEvent:getJudgement()
    return self._judgement
end

function NoteHitEvent:getHealthGain()
    return self._healthGain
end

function NoteHitEvent:showJudgement()
    return self._showJudgement
end

function NoteHitEvent:showCombo()
    return self._showCombo
end

function NoteHitEvent:showNoteSplash()
    return self._showNoteSplash
end

return NoteHitEvent