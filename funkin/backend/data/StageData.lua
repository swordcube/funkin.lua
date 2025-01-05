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
--- @enum funkin.backend.data.StageObjectType
---
local StageObjectType = {
    sprite = "sprite",
    box = "box",
    spectator = "spectator",
    gf = "gf",
    girlfriend = "girlfriend",
    opponent = "opponent",
    dad = "dad",
    player = "player",
    bf = "bf",
    boyfriend = "boyfriend",
}

---
--- @class funkin.backend.data.StageObjectData
---
local StageObjectData = {
    tag = nil, --- @type string? The tag of the object. (only optional for character types)
    type = nil, --- @type "sprite"|"box"|"spectator"|"gf"|"girlfriend"|"opponent"|"dad"|"player"|"bf"|"boyfriend"

    properties = nil, --- @type table<string, any>
}

---
--- @class funkin.backend.data.StageData
---
local StageData = {
    zoom = nil, --- @type number
    folder = nil, --- @type string

    objects = nil, --- @type table<funkin.backend.data.StageObjectData>
    cameraPosition = nil, --- @type {x: number, y: number}?
}

---
--- @param  stage  string  The name of the stage to load.
---
--- @return funkin.backend.data.StageData?
---
function StageData.get(stage)
    if not File.exists(Paths.json(stage, "data/stages")) then
        Log.warn(nil, nil, nil, "Stage data for " .. stage .. " doesn't exist!")
        return nil
    end
    return Json.parse(File.read(Paths.json(stage, "data/stages")))
end

return StageData