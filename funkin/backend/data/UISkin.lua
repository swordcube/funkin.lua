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
--- @class funkin.backend.data.UISkinAnimationData
---
local UISkinAnimationData = {
    name = nil, --- @type string
    prefix = nil, --- @type string?
    indices = nil, --- @type table<table<integer>>?
    fps = nil, --- @type integer
    looped = nil, --- @type boolean
    offsets = nil, --- @type table<{x: number, y: number}>
}

---
--- @class funkin.backend.data.UISkinGenericData
---
local UISkinGenericData = {
    scale = nil, --- @type number
    spacing = nil, --- @type number

    folder = nil, --- @type string
    texture = nil, --- @type string

    atlasType = nil, --- @type funkin.backend.enums.AtlasType
    gridSize = nil, --- @type {x: number, y: number}?

    animations = nil, --- @type table<funkin.backend.data.UISkinAnimationData>
    offset = nil, --- @type {x: number, y: number}

    antialiasing = nil --- @type boolean?
}

---
--- @class funkin.backend.data.UISkinCountdownData
---
local UISkinCountdownData = {
    scale = nil, --- @type number

    textureFolder = nil, --- @type string
    texture = nil, --- @type string

    soundFolder = nil, --- @type string
    sounds = nil, --- @type table<string>

    atlasType = nil, --- @type funkin.backend.enums.AtlasType
    gridSize = nil, --- @type {x: number, y: number}?

    animations = nil, --- @type table<funkin.backend.data.UISkinAnimationData>
    offset = nil, --- @type {x: number, y: number}

    antialiasing = nil --- @type boolean?
}

---
--- @class funkin.backend.data.UISkinHealthBarData
---
local UISkinHealthBarData = {
    scale = nil, --- @type number
    
    folder = nil, --- @type string
    texture = nil, --- @type string

    padding = nil, --- @type {x: number, y: number}
    offset = nil --- @type {x: number, y: number}
}

---
--- @class funkin.backend.data.UISkin
---
local UISkin = {
    judgements = nil, --- @type funkin.backend.data.UISkinGenericData
    combo = nil, --- @type funkin.backend.data.UISkinGenericData
    countdown = nil, --- @type funkin.backend.data.UISkinCountdownData
    healthBar = nil --- @type funkin.backend.data.UISkinHealthBarData
}

---
--- @param  uiSkin  string  The name of the noteskin to load.
---
--- @return funkin.backend.data.UISkin?
---
function UISkin.get(uiSkin)
    if not Cache.uiSkinCache[uiSkin] then
        Cache.uiSkinCache[uiSkin] = Json.parse(File.read(Paths.uiSkin(uiSkin)))
    end
    return Cache.uiSkinCache[uiSkin]
end

return UISkin