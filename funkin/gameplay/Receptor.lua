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

local dirs = {"left", "down", "up", "right"}
local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin

---
--- @class funkin.gameplay.Receptor : chip.graphics.Sprite
---
local Receptor = Sprite:extend("Receptor", ...)

function Receptor:constructor(x, y, lane, skin)
    Receptor.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._skin = nil --- @type string

    ---
    --- @protected
    ---
    self._lane = lane --- @type integer

    ---
    --- @protected
    ---
    self._initialWidth = 0.0 --- @type integer

    ---
    --- @protected
    ---
    self._initialHeight = 0.0 --- @type integer

    ---
    --- @protected
    ---
    self._confirmTimer = nil --- @type chip.utils.Timer?

    self:setSkin(skin)
end

function Receptor:getLaneID()
    return self._lane
end

function Receptor:setLaneID(id)
    self._lane = id % 4
    self.animation:play(dirs[self._lane + 1] .. " static")

    self._initialWidth = self:getFrameWidth()
    self._initialHeight = self:getFrameHeight()

    self.offset:set((self:getFrameWidth() - self._initialWidth) * 0.5, (self:getFrameHeight() - self._initialHeight) * 0.5)
end

function Receptor:getSkin()
    return self._skin
end

---
--- @param  skin  string
--- @param  json  funkin.backend.data.NoteSkin
---
function Receptor:setSkin(skin)
    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?

    if json.receptors.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.receptors.texture, "images/" .. json.receptors.folder))
        for i = 1, #json.receptors.animations do
            local animData = json.receptors.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = dirs[j] .. " " .. animData.name --- @type string
                if animData.indices and #animData.indices > 0 then
                    self.animation:addByIndices(animName, animData.prefixes[j], animData.indices[j], animData.fps, animData.looped)
                else
                    self.animation:addByPrefix(animName, animData.prefixes[j], animData.fps, animData.looped)
                end
                if animData.offsets then
                    self.animation:setOffset(animName, animData.offsets[j].x, animData.offsets[j].y)
                end
            end
        end
    
    elseif json.receptors.atlasType == "grid" then
        self:loadTexture(Paths.image(json.receptors.texture, "images/" .. json.receptors.folder), true, json.receptors.gridSize.x, json.receptors.gridSize.y)
        for i = 1, #json.receptors.animations do
            local animData = json.receptors.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = dirs[j] .. " " .. animData.name --- @type string
                self.animation:add(animName, animData.indices[j], animData.fps, animData.looped)
            end
        end

    elseif json.receptors.atlasType == "animate" then
        -- TODO
    end
    -- TODO: fix autobatch.lua to allow this to actually function
    if json.receptors.antialiasing ~= nil then
        self:setAntialiasing(json.receptors.antialiasing)
    else
        self:setAntialiasing(true)
    end
    self.scale:set(json.receptors.scale, json.receptors.scale)
    self:setLaneID(self:getLaneID())

    self.offset:set(json.receptors.offset.x, json.receptors.offset.y)
    self._skin = skin
end

---
--- @param  confirm    boolean
--- @param  duration?  number
--- @param  cpu?       boolean
---
function Receptor:press(confirm, duration, cpu)
    local json = NoteSkin.get(self:getSkin()) --- @type funkin.backend.data.NoteSkin?

    self.animation:play(dirs[self._lane + 1] .. (confirm and " confirm" or " press"), true)
    self.offset:set(
        json.receptors.offset.x + ((self:getFrameWidth() - self._initialWidth) * 0.5),
        json.receptors.offset.y + ((self:getFrameHeight() - self._initialHeight) * 0.5)
    )
    if duration then
        if self._confirmTimer then
            self._confirmTimer:free()
        end
        self._confirmTimer = Timer:new() --- @type chip.utils.Timer
        self._confirmTimer:start(duration / 1000.0, function()
            if cpu then
                self:release()
            
            elseif confirm and self.animation:getCurrentAnimationName():endsWith("confirm") then
                self.animation:play(dirs[self._lane + 1] .. " press", true)
                self.offset:set(
                    json.receptors.offset.x + ((self:getFrameWidth() - self._initialWidth) * 0.5),
                    json.receptors.offset.y + ((self:getFrameHeight() - self._initialHeight) * 0.5)
                )
            end
            self._confirmTimer = nil
        end)
    end
end

function Receptor:release()
    local json = NoteSkin.get(self:getSkin()) --- @type funkin.backend.data.NoteSkin?

    self.animation:play(dirs[self._lane + 1] .. " static")
    self.offset:set(
        json.receptors.offset.x + ((self:getFrameWidth() - self._initialWidth) * 0.5),
        json.receptors.offset.y + ((self:getFrameHeight() - self._initialHeight) * 0.5)
    )
end

return Receptor