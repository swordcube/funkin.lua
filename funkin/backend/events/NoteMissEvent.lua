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
--- @class funkin.backend.events.NoteMissEvent : funkin.backend.events.CancellableEvent
---
local NoteMissEvent = CancellableEvent:extend("NoteMissEvent", ...)

function NoteMissEvent:constructor(note, player, breaksCombo, score, healthLoss, showJudgement, showCombo)
    NoteMissEvent.super.constructor(self)

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
    self._healthLoss = healthLoss --- @type number

    ---
    --- @protected
    ---
    self._showJudgement = showJudgement --- @type boolean

    ---
    --- @protected
    ---
    self._showCombo = showCombo --- @type boolean
end

function NoteMissEvent:getNote()
    return self._note
end

function NoteMissEvent:getPlayer()
    return self._player
end

function NoteMissEvent:getStrumLine()
    return self._note:getStrumLine()
end

function NoteMissEvent:getReceptor()
    local strumLine = self._note:getStrumLine() --- @type funkin.gameplay.StrumLine
    return strumLine.receptors:getMembers()[self._note:getLane() + 1]
end

function NoteMissEvent:getTime()
    return self._note:getTime()
end

function NoteMissEvent:getLane()
    return self._note:getLane()
end

function NoteMissEvent:getDirection()
    return self._note:getLane()
end

function NoteMissEvent:getNoteData()
    return self._note:getLane()
end

function NoteMissEvent:getLength()
    return self._note:getLength()
end

function NoteMissEvent:getSustainLength()
    return self._note:getLength()
end

function NoteMissEvent:getNoteType()
    return self._note:getType()
end

function NoteMissEvent:breaksCombo()
    return self._breaksCombo
end

function NoteMissEvent:getScore()
    return self._score
end

function NoteMissEvent:getHealthLoss()
    return self._healthLoss
end

function NoteMissEvent:showJudgement()
    return self._showJudgement
end

function NoteMissEvent:showCombo()
    return self._showCombo
end

return NoteMissEvent