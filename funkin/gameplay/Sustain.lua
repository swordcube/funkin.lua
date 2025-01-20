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

---@diagnostic disable: invisible

local _inherit_ = "inherit"

local max = math.max

local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin

---
--- @class funkin.gameplay.Sustain : chip.graphics.CanvasLayer
---
local Sustain = CanvasLayer:extend("Sustain", ...)

function Sustain:constructor(x, y)
    Sustain.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._length = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._skin = nil --- @type string

    ---
    --- @protected
    ---
    self._note = nil --- @type funkin.gameplay.Note

    ---
    --- @protected
    ---
    self._body = TiledSprite:new() --- @type chip.graphics.TiledSprite
    self._body:setHorizontalRepeat(false)
    self:add(self._body)

    ---
    --- @protected
    ---
    self._tail = Sprite:new() --- @type chip.graphics.Sprite
    self:add(self._tail)
end

function Sustain:getNote()
    return self._note
end

---
--- @param  note  funkin.gameplay.Note
---
function Sustain:setNote(note)
    self._note = note
end

function Sustain:setSkin(skin)
    if self._skin == skin then
        return
    end
    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?

    if json.sustains.atlasType == "sparrow" then
        self._body:setFrames(Paths.getSparrowAtlas(json.sustains.folder .. "/" .. json.sustains.texture))
        self._tail:setFrames(Paths.getSparrowAtlas(json.sustains.folder .. "/" .. json.sustains.texture))
        
        for i = 1, #json.sustains.animations do
            local animData = json.sustains.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = Constants.NOTE_DIRECTIONS[j] .. " " .. animData.name --- @type string
                if animData.indices and #animData.indices > 0 then
                    self._body.animation:addByIndices(animName, animData.prefixes[j], animData.indices[j], animData.fps, animData.looped)
                    self._tail.animation:addByIndices(animName, animData.prefixes[j], animData.indices[j], animData.fps, animData.looped)
                else
                    self._body.animation:addByPrefix(animName, animData.prefixes[j], animData.fps, animData.looped)
                    self._tail.animation:addByPrefix(animName, animData.prefixes[j], animData.fps, animData.looped)
                end
            end
        end
    elseif json.sustains.atlasType == "grid" then
        self._body:loadTexture(Paths.image(json.sustains.folder .. "/" .. json.sustains.texture), true, json.sustains.gridSize.x, json.sustains.gridSize.y)
        self._tail:loadTexture(Paths.image(json.sustains.folder .. "/" .. json.sustains.texture), true, json.sustains.gridSize.x, json.sustains.gridSize.y)
        
        for i = 1, #json.sustains.animations do
            local animData = json.sustains.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = Constants.NOTE_DIRECTIONS[j] .. " " .. animData.name --- @type string
                self._body.animation:add(animName, animData.indices[j], animData.fps, animData.looped)
                self._tail.animation:add(animName, animData.indices[j], animData.fps, animData.looped)
            end
        end
    
    elseif json.sustains.atlasType == "animate" then
        -- TODO
    end
    if json.sustains.antialiasing ~= nil then
        self._body:setAntialiasing(json.sustains.antialiasing)
        self._tail:setAntialiasing(json.sustains.antialiasing)
    else
        self._body:setAntialiasing(true)
        self._tail:setAntialiasing(true)
    end
    self._body.animation:play(Constants.NOTE_DIRECTIONS[self._note:getLane() + 1] .. " hold")
    self._body.scale:set(json.sustains.scale, json.sustains.scale)
    self._body.offset:set(json.sustains.offset.x, json.sustains.offset.y)
    
    self._tail.animation:play(Constants.NOTE_DIRECTIONS[self._note:getLane() + 1] .. " tail")
    self._tail.scale:set(json.sustains.scale, json.sustains.scale)
    self._tail.offset:set(json.sustains.offset.x, json.sustains.offset.y)

    self._skin = skin
end

---
--- @param  note  funkin.gameplay.Note
--- @param  skin  string
---
function Sustain:setup(note, skin)
    self:revive()
    self:setPosition(-999999, -999999)
    
    self._note = note
    self:setSkin(skin)
    
    self._body.animation:play(Constants.NOTE_DIRECTIONS[note:getLane() + 1] .. " hold")
    self._body:setVerticalPadding(1.5)
    
    self._tail.animation:play(Constants.NOTE_DIRECTIONS[note:getLane() + 1] .. " tail")
    self._tail:setClipRect(nil)

    self._body:setUpdateMode(_inherit_)
    self._tail:setUpdateMode(_inherit_)

    self._body:setVisibility(true)
    self._tail:setVisibility(true)

    self._body:setAlpha(1.0)
    self._tail:setAlpha(1.0)

    self._body:setTint(Color.WHITE)
    self._tail:setTint(Color.WHITE)

    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?
    if json.sustains.antialiasing ~= nil then
        self._body:setAntialiasing(json.sustains.antialiasing)
        self._tail:setAntialiasing(json.sustains.antialiasing)
    else
        self._body:setAntialiasing(true)
        self._tail:setAntialiasing(true)
    end
end

function Sustain:getBody()
    return self._body
end

function Sustain:getTail()
    return self._tail
end

function Sustain:getLength()
    return self._length
end

---
--- @param  value  number  The new length of the sustain.
---
function Sustain:setLength(value)
    local body, tail = self._body, self._tail
    local calcHeight = value - tail:getHeight()
    
    value = max(value, 0.0)
    self._length = value
    
    local bodyLength = max((value - tail:getHeight()) / body.scale.y, 0.0)
    body:setVerticalLength(bodyLength)
    
    local note = self._note --- @type funkin.gameplay.Note
    local strumLine = note:getStrumLine() --- @type funkin.gameplay.StrumLine

    local scrollSpeed = strumLine:getScrollSpeed() / Engine.timeScale
    local scrollMult = (scrollSpeed < 0.0 and -1.0 or 1.0)

    if strumLine:isDownscroll() then
        scrollMult = -scrollMult
    end
    local downscroll = scrollMult < 0.0
    body.flipY = not downscroll
    tail.flipY = downscroll
    
    self:setVisibility(value > 0)

    if downscroll then
        body:setY(tail:getHeight())
        tail:setY(0.0)
    else
        body:setY(0.0)
        tail:setY(calcHeight)
    end
    if note:wasHit() and not note:wasMissed() then
        local receptor = strumLine.receptors:getMembers()[note:getLane() + 1]
        local receptorCenter = (strumLine:getY() + receptor:getY()) + (receptor._initialHeight * 0.5)
    
        local py = 0.0
        local p = self._parent
        while p do
            if p:is(CanvasLayer) and not p:is(Scene) then
                py = py + p:getY()
            end
            p = p._parent
        end
        local ry = py + (self:getY() + tail:getY())
        local clipRect = (tail:getClipRect() or Rect:new()):set(0, 0, tail:getFrameWidth(), tail:getFrameHeight())
        
        if downscroll then
            clipRect.height = (receptorCenter - ry) / tail.scale.y
            clipRect.y = tail:getFrameHeight() - clipRect.height
        else
            clipRect.y = (receptorCenter - ry) / tail.scale.y
            clipRect.height = (clipRect.height - clipRect.y)
        end
        tail:setClipRect(clipRect)
    end
end

return Sustain