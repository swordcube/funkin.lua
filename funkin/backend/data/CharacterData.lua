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
--- @class funkin.backend.data.CharacterData
---
local CharacterData = {
    ---
    --- @type funkin.backend.data.HealthIconData?
    ---
    healthIcon = nil,

    ---
    --- @type funkin.backend.enums.AtlasType
    ---
    atlasType = nil,

    ---
    --- @type string
    ---
    atlasPath = nil,

    ---
    --- @type table<string, boolean>?
    ---
    gridSize = nil,

    ---
    --- @type table<funkin.backend.data.CharacterAnimationData>
    ---
    animations = nil,

    ---
    --- @type {x: number, y: number}?
    ---
    position = nil,

    ---
    --- @type {x: number, y: number}?
    ---
    camera = nil,

    ---
    --- @type number?
    ---
    scale = nil,

    ---
    --- @type table<string, boolean>?
    ---
    flip = nil,

    ---
    --- @type boolean?
    ---
    isPlayer = nil,

    ---
    --- @type boolean?
    ---
    antialiasing = nil,

    ---
    --- @type number?
    ---
    singDuration = nil,

    ---
    --- @type table<string>?
    ---
    danceSteps = nil,

    ---
    --- @type integer
    ---
    danceFrequency = nil
}

---
--- @param  character  string  The name of the character to load.
---
--- @return funkin.backend.data.CharacterData?
---
function CharacterData.get(character)
    if not File.exists(Paths.character(character)) then
        Log.warn(nil, nil, nil, "Character data for " .. character .. " doesn't exist!")
        return nil
    end
    return Json.parse(File.read(Paths.character(character)))
end

return CharacterData