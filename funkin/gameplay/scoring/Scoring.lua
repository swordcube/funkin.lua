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

---
--- @class funkin.gameplay.scoring.Scoring
---
local Scoring = {}

---
--- The currently active scoring system.
--- 
--- Used to determine score and judgements
--- for notes during gameplay.
---
Scoring.currentSystem = require("funkin.gameplay.scoring.PBotSystem"):new() --- @type funkin.gameplay.scoring.ScoringSystem

---
--- Returns a list of every judgement type,
--- from best to worst.
---
--- @return table<string>
---
function Scoring.getJudgements()
    local system = Scoring.currentSystem
    return system:getJudgements()
end

---
--- Returns the timing of a given judgement.
---
--- @param  judgement  string  The judgement to get the timing of.
--- @return number
---
function Scoring.getJudgementTiming(judgement)
    local system = Scoring.currentSystem
    return system:getJudgementTiming(judgement)
end

---
--- Returns the accuracy score of a given judgement.
---
--- @param  judgement  string  The judgement to get the accuracy score of.
--- @return number
---
function Scoring.getAccuracyScore(judgement)
    local system = Scoring.currentSystem
    return system:getAccuracyScore(judgement)
end

---
--- Returns the judgement of a given note.
---
--- @param  note       funkin.gameplay.Note  The note to get the judgement from.
--- @param  timestamp  number                The timestamp that the note was hit at. (in milliseconds)
--- 
--- @return string?
---
function Scoring.judgeNote(note, timestamp)
    local system = Scoring.currentSystem
    return system:judgeNote(note, timestamp)
end

---
--- Returns the score of a given note.
---
--- @param  note       funkin.gameplay.Note  The note to get the score from.
--- @param  timestamp  number                The timestamp that the note was hit at. (in milliseconds)
--- 
--- @return integer
---
function Scoring.scoreNote(note, timestamp)
    local system = Scoring.currentSystem
    return system:scoreNote(note, timestamp)
end

---
--- Returns whether or not a splash should be shown for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return boolean
---
function Scoring.splashAllowed(judgement)
    local system = Scoring.currentSystem
    return system:splashAllowed(judgement)
end

---
--- Returns whether or not your combo should be broken for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return boolean
---
function Scoring.breaksCombo(judgement)
    local system = Scoring.currentSystem
    return system:breaksCombo(judgement)
end

---
--- Returns the health gain multiplier for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return number
---
function Scoring.getHealthGainMultiplier(judgement)
    local system = Scoring.currentSystem
    return system:getHealthGainMultiplier(judgement)
end

---
--- Returns the rank of a given accuracy.
---
--- @param  accuracy  number  The accuracy to get the rank of.
--- 
--- @return string
---
function Scoring.getRank(accuracy)
    local system = Scoring.currentSystem
    return system:getRank(accuracy)
end

return Scoring