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

local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin

---
--- @class funkin.gameplay.NoteSplash : chip.graphics.Sprite
---
local NoteSplash = Sprite:extend("NoteSplash", ...)

function NoteSplash:constructor(x, y, lane, skin)
    NoteSplash.super.constructor(self, x, y)

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
    self._strumLine = nil --- @type funkin.gameplay.StrumLine

    ---
    --- @protected
    ---
    self._totalAnims = 0 --- @type integer

    self.animation:setCompletionCallback(function(_)
        self:kill()
    end)
    self:setSkin(skin)
end

function NoteSplash:getLane()
    return self._lane
end

function NoteSplash:setLane(id)
    self._lane = id % 4
    self.animation:play(Constants.NOTE_DIRECTIONS[self._lane + 1] .. " splash" .. math.random(1, self._totalAnims))
end

function NoteSplash:getSkin()
    return self._skin
end

---
--- @param  skin  string
---
function NoteSplash:setSkin(skin)
    if self._skin == skin then
        return
    end
    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?

    if json.splashes.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.splashes.texture, "images/" .. json.splashes.folder))
        for i = 1, #json.splashes.animations do
            local animData = json.splashes.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local prefixes = animData.prefixes[j]
                for k = 1, #prefixes do
                    local animName = Constants.NOTE_DIRECTIONS[j] .. " splash" .. tostring(k) --- @type string
                    if animData.indices and #animData.indices > 0 then
                        self.animation:addByIndices(animName, prefixes[k], animData.indices[j][k], animData.fps, animData.looped)
                    else
                        self.animation:addByPrefix(animName, prefixes[k], animData.fps, animData.looped)
                    end
                    if animData.offsets then
                        self.animation:setOffset(animName, animData.offsets[j][k].x, animData.offsets[j][k].y)
                    end
                end
                self._totalAnims = #prefixes
            end
        end
    elseif json.splashes.atlasType == "grid" then
        -- TODO
    elseif json.splashes.atlasType == "animate" then
        -- TODO
    end
    self.scale:set(json.splashes.scale, json.splashes.scale)
    self:setLane(self:getLane())

    self:setAlpha(json.splashes.alpha or 0.6)

    self.offset:set(json.splashes.offset.x, json.splashes.offset.y)
    self._skin = skin
end

function NoteSplash:getStrumLine()
    return self._strumLine
end

function NoteSplash:setStrumLine(strumLine)
    self._strumLine = strumLine
end

---
--- @param  strumLine  funkin.gameplay.StrumLine  The strumline that the note splash belongs to.
--- @param  lane       integer                    The lane that the splash belongs to. (from 0 to 4)
--- @param  skin       string                     The skin of the note splash.
---
function NoteSplash:setup(strumLine, lane, skin)
    self:setSkin(skin)
    self:setLane(lane)

    self:revive()
    self:setStrumLine(strumLine)

    local r = strumLine.receptors:getMembers()[lane + 1] --- @type funkin.gameplay.Receptor
    self:setPosition(
        r:getX() - (self:getWidth() * 0.5),
        r:getY() - (self:getHeight() * 0.5)
    )
end

return NoteSplash