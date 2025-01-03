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
--- @class funkin.backend.Highscore
--- 
--- A class for managing highscores.
---
local Highscore = {
    ---
    --- @protected
    --- @type chip.utils.Save
    ---
    _save = Save:new(),

    ---
    --- @protected
    --- @type funkin.backend.data.HighscoreData
    ---
    _defaultData = {
        score = 0,
        misses = 0,

        maxCombo = 0,
        totalNotesHit = nil,

        totalJudgements = {
            sick = 0,
            good = 0,
            bad = 0,
            shit = 0,
            miss = 0
        },
        accuracy = 0.0,
        rank = "N/A",
        
        isValid = false
    }
}

function Highscore.init()
    local save = Highscore._save
    save:bind("highscores", "swordcube/funkin.lua")
end

---
--- @param  song        string
--- @param  difficulty  string
--- @param  mod         string?
--- 
--- @return funkin.backend.data.HighscoreData
---
function Highscore.getScoreData(song, difficulty, mod)
    if mod then
        local data = Highscore._save.data[song:lower() .. "-" .. difficulty:lower() .. "-" .. mod] --- @type funkin.backend.data.HighscoreData
        if data and data.isValid then
            return data
        end
    end
    local data = Highscore._save.data[song:lower() .. "-" .. difficulty:lower()] --- @type funkin.backend.data.HighscoreData
    if data and data.isValid then
        return data
    end
    return Highscore._defaultData
end

---
--- Sets the highscore data for a given song.
--- and difficulty.
--- 
--- **WARNING**: You must call `Highscore.save()` manually
--- after this, as this function does not automatically save the data.
---
--- @param  song        string
--- @param  difficulty  string
--- @param  mod         string
--- @param  data        funkin.backend.data.HighscoreData
---
function Highscore.setScoreData(song, difficulty, mod, data)
    Highscore._save.data[song:lower() .. "-" .. difficulty:lower() .. (mod and ("-" .. mod) or "")] = data
end

function Highscore.save()
    local save = Highscore._save
    save:flush()
end

return Highscore