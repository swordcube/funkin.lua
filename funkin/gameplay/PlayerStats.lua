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

local clamp = math.clamp

local Scoring = require("funkin.gameplay.scoring.Scoring") --- @type funkin.gameplay.scoring.Scoring

---
--- @class funkin.gameplay.PlayerStats
---
local PlayerStats = Class:extend("PlayerStats", ...)

function PlayerStats:constructor()
    ---
    --- @protected
    ---
    self._score = 0 --- @type integer

    self.misses = 0 --- @type integer
    self.comboBreaks = 0 --- @type integer

    self.combo = 0 --- @type integer
    self.maxCombo = 0 --- @type integer
    self.missCombo = 0 --- @type integer

    self.judgementHits = {miss = 0} --- @type table<string, integer>

    local judgements = Scoring.getJudgements()
    for i = 1, #judgements do
        self.judgementHits[judgements[i]] = 0 
    end
    self.totalNotesHit = 0 --- @type integer
    self.accuracyScore = 0.0 --- @type number

    self.health = 1.0 --- @type number

    self.minHealth = 0.0 --- @type number
    self.maxHealth = 2.0 --- @type number
end

function PlayerStats:reset()
    self._score = 0

    self.misses = 0
    self.comboBreaks = 0

    self.combo = 0
    self.maxCombo = 0
    self.missCombo = 0

    self.judgementHits = {}

    self.totalNotesHit = 0
    self.accuracyScore = 0.0

    self.health = 1.0

    self.minHealth = 0.0
    self.maxHealth = 2.0
end

function PlayerStats:increaseScore(by)
    self._score = self._score + by
end

function PlayerStats:increaseMisses()
    local newMissCount = self.misses + 1
    self.misses = newMissCount
    self.judgementHits.miss = newMissCount
end

function PlayerStats:increaseComboBreaks()
    self.comboBreaks = self.comboBreaks + 1
end

function PlayerStats:increaseCombo()
    self.combo = self.combo + 1
    if self.combo > self.maxCombo then
        self.maxCombo = self.maxCombo + 1
    end
end

function PlayerStats:increaseMissCombo()
    self.missCombo = self.missCombo + 1
end

function PlayerStats:resetCombo()
    self.combo = 0
end

function PlayerStats:resetMissCombo()
    self.missCombo = 0
end

function PlayerStats:increaseHealth(by)
    self.health = clamp(self.health + by, self.minHealth, self.maxHealth)
end

function PlayerStats:increaseTotalNotesHit()
    self.totalNotesHit = self.totalNotesHit + 1
end

function PlayerStats:increaseAccuracyScore(by)
    self.accuracyScore = self.accuracyScore + by
end

---
--- @return  number  integer  Your current score.
---
function PlayerStats:getScore()
    return math.floor(self._score)
end

---
--- @return  number  accuracy  Your current accuracy. (from 0 to 1)
---
function PlayerStats:getAccuracy()
    if (self.totalNotesHit + self.misses) == 0 or self.accuracyScore == 0.0 then
        return 0.0
    end
    return self.accuracyScore / (self.totalNotesHit + self.misses)
end

---
--- @param  judgement  string  The judgement to increase the hit count of.
---
function PlayerStats:increaseJudgementHits(judgement)
    self.judgementHits[judgement] = self.judgementHits[judgement] + 1
end

return PlayerStats