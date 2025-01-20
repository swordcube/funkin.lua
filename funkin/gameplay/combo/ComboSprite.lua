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

local UISkin = require("funkin.backend.data.UISkin") --- @type funkin.backend.data.UISkin
local Scoring = require("funkin.gameplay.scoring.Scoring") --- @type funkin.gameplay.scoring.Scoring

---
--- @class funkin.gameplay.combo.ComboSprite : chip.graphics.Sprite
---
local ComboSprite = Sprite:extend("ComboSprite", ...)

function ComboSprite:constructor(x, y)
    ComboSprite.super.constructor(self, x, y)

    self._tween = nil --- @type chip.tweens.Tween
end

---
--- @param  skin  string
---
function ComboSprite:setJudgementSkin(skin)
    local json = UISkin.get(skin) --- @type funkin.backend.data.UISkin?
    if json.judgements.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.judgements.folder .. "/" .. json.judgements.texture))
        for i = 1, #json.judgements.animations do
            local animData = json.judgements.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            if animData.indices and #animData.indices > 0 then
                self.animation:addByIndices(animData.name, animData.prefix, animData.indices, animData.fps, animData.looped)
            else
                self.animation:addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped)
            end
        end
    elseif json.judgements.atlasType == "grid" then
        self:loadTexture(Paths.image(json.judgements.folder .. "/" .. json.judgements.texture), true, json.judgements.gridSize.x, json.judgements.gridSize.y)
        for i = 1, #json.judgements.animations do
            local animData = json.judgements.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            self.animation:add(animData.name, animData.indices, animData.fps, animData.looped)
        end
    
    elseif json.judgements.atlasType == "animate" then
        -- TODO
    end
    self.animation:play(Scoring.getJudgements()[1])
    self.scale:set(json.judgements.scale, json.judgements.scale)
end

---
--- @param  skin  string
---
function ComboSprite:setComboSkin(skin)
    local json = UISkin.get(skin) --- @type funkin.backend.data.UISkin?
    if json.combo.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.combo.folder .. "/" .. json.combo.texture))
        for i = 1, #json.combo.animations do
            local animData = json.combo.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            if animData.indices and #animData.indices > 0 then
                self.animation:addByIndices(animData.name, animData.prefix, animData.indices, animData.fps, animData.looped)
            else
                self.animation:addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped)
            end
        end
    
    elseif json.combo.atlasType == "grid" then
        self:loadTexture(Paths.image(json.combo.folder .. "/" .. json.combo.texture), true, json.combo.gridSize.x, json.combo.gridSize.y)
        for i = 1, #json.combo.animations do
            local animData = json.combo.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            self.animation:add(animData.name, animData.indices, animData.fps, animData.looped)
        end
    
    elseif json.combo.atlasType == "animate" then
        -- TODO
    end
    self.scale:set(json.combo.scale, json.combo.scale)
end

return ComboSprite