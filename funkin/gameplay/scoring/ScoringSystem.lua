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
--- @class funkin.gameplay.scoring.ScoringSystem
---
local ScoringSystem = Class:extend("ScoringSystem", ...)

---
--- Returns a list of every judgement type,
--- from best to worst.
---
--- @return table<string>
---
function ScoringSystem:getJudgements()
    return {}
end

---
--- Returns the timing of a given judgement.
---
--- @param  judgement  string  The judgement to get the timing of.
--- @return number
---
function ScoringSystem:getJudgementTiming(judgement)
    return math.huge
end

---
--- Returns the accuracy score of a given judgement.
---
--- @param  judgement  string  The judgement to get the accuracy score of.
--- @return number
---
function ScoringSystem:getAccuracyScore(judgement)
    return 0.0
end

---
--- Returns the judgement of a given note.
---
--- @param  note       funkin.gameplay.Note  The note to get the judgement from.
--- @param  timestamp  number                The timestamp that the note was hit at. (in milliseconds)
--- 
--- @return string?
---
function ScoringSystem:judgeNote(note, timestamp)
    return nil
end

---
--- Returns the score of a given note.
---
--- @param  note       funkin.gameplay.Note  The note to get the score from.
--- @param  timestamp  number                The timestamp that the note was hit at. (in milliseconds)
--- 
--- @return integer
---
function ScoringSystem:scoreNote(note, timestamp)
    return 0
end

---
--- Returns whether or not a splash should be shown for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return boolean
---
function ScoringSystem:splashAllowed(judgement)
    return false
end

---
--- Returns whether or not your combo should be broken for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return boolean
---
function ScoringSystem:breaksCombo(judgement)
    return false
end

---
--- Returns the health gain multiplier for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return number
---
function ScoringSystem:getHealthGainMultiplier(judgement)
    return 1.0
end

---
--- Returns the rank of a given accuracy.
---
--- @param  accuracy  number  The accuracy to get the rank of.
--- 
--- @return string
---
function ScoringSystem:getRank(accuracy)
    return "N/A"
end

return ScoringSystem