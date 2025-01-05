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

local tblInsert = table.insert

---
--- @class funkin.backend.CoolUtil
---
local CoolUtil = {}

---
--- @param  name    string    The name of the folder containing the music, contained in `assets/music`.
--- @param  volume  number    The volume to play the music at. (defaults to `1.0`)
--- @param  loop    boolean?  Whether or not the music should loop. (defaults to `true`)
---
function CoolUtil.playMusic(name, volume, loop)
    if loop == nil then
        loop = true
    end
    BGM.play(Paths.music(name), loop)
    BGM.audioPlayer:setVolume(volume and volume or 1.0)

    local json = Json.decode(File.read(Paths.json("meta", "music/" .. name)))
    Conductor.instance:reset(json.bpm)
    Conductor.instance.music = BGM.audioPlayer
    Conductor.instance.timeSignature = Conductor.timeSignatureFromString(json.timeSignature)
end

---
--- @param  volume  number?   The volume to play the music at. (defaults to `1.0`)
--- @param  loop    boolean?  Whether or not the music should loop. (defaults to `true`)
---
function CoolUtil.playMenuMusic(volume, loop)
    CoolUtil.playMusic("freakyMenu", volume, loop)
end

---
--- @param  csv  string
---
--- @return table
---
function CoolUtil.parseCSV(csv)
    local list = {}
    local splitCSV = csv:trim():replace("\r", ""):split("\n")
    for i = 1, #splitCSV do
        ---
        --- @type string
        ---
        local line = splitCSV[i]
        tblInsert(list, line:split(","))
    end
    return list
end

return CoolUtil