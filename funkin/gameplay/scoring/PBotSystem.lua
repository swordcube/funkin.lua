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

local abs = math.abs
local exp = math.exp
local round = math.round

---
--- @class funkin.gameplay.scoring.PBotSystem : funkin.gameplay.scoring.ScoringSystem
---
local PBotSystem = Class:extend("PBotSystem", ...)

---
--- @protected
---
PBotSystem._judgements = {"killer", "sick", "good", "bad", "shit"}

PBotSystem.PERFECT_THRESHOLD = 5.0 --- @type number

PBotSystem.MISS_THRESHOLD = 160.0 --- @type number
PBotSystem.MISS_SCORE = 0 --- @type integer

PBotSystem.MIN_SCORE = 9.0 --- @type number
PBotSystem.MAX_SCORE = 500.0 --- @type number

PBotSystem.SCORING_OFFSET = 54.99 --- @type number
PBotSystem.SCORING_SLOPE = 0.080 --- @type number

---
--- Returns a list of every judgement type,
--- from best to worst.
---
--- @return table<string>
---
function PBotSystem:getJudgements()
    return PBotSystem._judgements
end

---
--- Returns the timing of a given judgement.
---
--- @param  judgement  string  The judgement to get the timing of.
--- @return number
---
function PBotSystem:getJudgementTiming(judgement)
    if judgement == "killer" then
        return 22.5
    
    elseif judgement == "sick" then
        return 45.0
    
    elseif judgement == "good" then
        return 90.0

    elseif judgement == "bad" then
        return 130.0

    elseif judgement == "shit" then
        return 160.0
    end
    return math.huge
end

---
--- Returns the accuracy score of a given judgement.
---
--- @param  judgement  string  The judgement to get the accuracy score of.
--- @return number
---
function PBotSystem:getAccuracyScore(judgement)
    if judgement == "killer" or judgement == "sick" then
        return 1.0
    
    elseif judgement == "good" then
        return 0.7

    elseif judgement == "bad" then
        return 0.3

    elseif judgement == "shit" then
        return 0.0
    end
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
function PBotSystem:judgeNote(note, timestamp)
    local judgements = PBotSystem._judgements
    local diff = abs(note:getTime() - timestamp)

    local result = judgements[#judgements]
    for i = 1, #judgements do
        local judgement = judgements[i]
        if diff <= self:getJudgementTiming(judgement) then
            result = judgement
            break
        end
    end
    return result
end

---
--- Returns the score of a given note.
---
--- @param  note       funkin.gameplay.Note  The note to get the score from.
--- @param  timestamp  number                The timestamp that the note was hit at. (in milliseconds)
--- 
--- @return integer
---
function PBotSystem:scoreNote(note, timestamp)
    local diff = abs(note:getTime() - timestamp)
    if diff >= PBotSystem.MISS_THRESHOLD then
        return PBotSystem.MISS_SCORE
    end
    if diff <= PBotSystem.PERFECT_THRESHOLD then
        return PBotSystem.MAX_SCORE
    end
    local factor = 1.0 - (1.0 / (1.0 + exp(-PBotSystem.SCORING_SLOPE * (diff - PBotSystem.SCORING_OFFSET))))
    return round(PBotSystem.MAX_SCORE * factor + PBotSystem.MIN_SCORE)
end

---
--- Returns whether or not a splash should be shown for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return boolean
---
function PBotSystem:splashAllowed(judgement)
    return judgement == "killer" or judgement == "sick"
end

---
--- Returns whether or not your combo should be broken for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return boolean
---
function PBotSystem:breaksCombo(judgement)
    if judgement == "shit" then
        return true
    end
    return false
end

---
--- Returns the health gain multiplier for a given judgement.
---
--- @param  judgement  string  The judgement to get the result from.
--- 
--- @return number
---
function PBotSystem:getHealthGainMultiplier(judgement)
    if judgement == "shit" or judgement == "bad" then
        return -3.15
    end
    return 1.0
end

---
--- Returns the rank of a given accuracy.
---
--- @param  accuracy  number  The accuracy to get the rank of.
--- 
--- @return string
---
function PBotSystem:getRank(accuracy)
    if accuracy == 1.0 then
        return "P" -- perfect

    elseif accuracy >= 0.9 then
        return "E" -- excellent

    elseif accuracy >= 0.8 then
        return "GG" -- great

    elseif accuracy >= 0.6 then
        return "G" -- good
    end
    return "F" -- loss
end

return PBotSystem