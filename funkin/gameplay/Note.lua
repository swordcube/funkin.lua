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

local abs = math.abs
local max = math.max
local _inherit_ = "inherit"

local Sustain = require("funkin.gameplay.Sustain") --- @type funkin.gameplay.Sustain
local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin

---
--- @class funkin.gameplay.Note : chip.graphics.Sprite
---
local Note = Sprite:extend("Note", ...)

function Note:constructor(x, y)
    Note.super.constructor(self, x, y)

    ---
    --- @protected
    ---
    self._strumLine = nil --- @type funkin.gameplay.StrumLine

    ---
    --- @protected
    ---
    self._skin = nil --- @type string

    ---
    --- @protected
    ---
    self._time = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._lane = 0 --- @type integer

    ---
    --- @protected
    ---
    self._length = 0.0 --- @type number

    ---
    --- @protected
    ---
    self._type = "Default" --- @type string

    ---
    --- @protected
    ---
    self._attachedConductor = Conductor.instance --- @type funkin.backend.Conductor

    ---
    --- @protected
    ---
    self._wasHit = false --- @type boolean

    ---
    --- @protected
    ---
    self._missed = false --- @type boolean

    ---
    --- @protected
    ---
    self._sustain = Sustain:new() --- @type funkin.gameplay.Sustain
end

function Note:getTime()
    return self._time
end

---
--- @param  time  number
---
function Note:setTime(time)
    self._time = time
end

function Note:getLaneID()
    return self._lane
end

---
--- @param  id  integer
---
function Note:setLaneID(id)
    self._lane = id % 4
    self.animation:play(dirs[self._lane + 1] .. " scroll")
end

function Note:getLength()
    return self._length
end

---
--- @param  length  number
---
function Note:setLength(length)
    self._length = length
end

function Note:getType()
    return self._type
end

---
--- @param  type  string
---
function Note:setType(type)
    self._type = type
end

function Note:getSkin()
    return self._skin
end

---
--- @param  skin  string
--- @param  json  funkin.backend.data.NoteSkin
---
function Note:setSkin(skin)
    if self._skin == skin then
        return
    end
    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?

    if json.notes.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.notes.texture, "images/" .. json.notes.folder))
        for i = 1, #json.notes.animations do
            local animData = json.notes.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = dirs[j] .. " " .. animData.name --- @type string
                if animData.indices and #animData.indices > 0 then
                    self.animation:addByIndices(animName, animData.prefixes[j], animData.indices[j], animData.fps, animData.looped)
                else
                    self.animation:addByPrefix(animName, animData.prefixes[j], animData.fps, animData.looped)
                end
            end
        end
    elseif json.notes.atlasType == "grid" then
        self:loadTexture(Paths.image(json.notes.texture, "images/" .. json.notes.folder), true, json.notes.gridSize.x, json.notes.gridSize.y)
        for i = 1, #json.notes.animations do
            local animData = json.notes.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            for j = 1, 4 do
                local animName = dirs[j] .. " " .. animData.name --- @type string
                self.animation:add(animName, animData.indices[j], animData.fps, animData.looped)
            end
        end
    
    elseif json.notes.atlasType == "animate" then
        -- TODO
    end
    if json.notes.antialiasing ~= nil then
        self:setAntialiasing(json.notes.antialiasing)
    else
        self:setAntialiasing(true)
    end
    self.scale:set(json.notes.scale, json.notes.scale)
    self.animation:play(dirs[self._lane + 1] .. " scroll")

    self._skin = skin
end

function Note:getStrumLine()
    return self._strumLine
end

---
--- @param  strumLine  funkin.gameplay.StrumLine
---
function Note:setStrumLine(strumLine)
    self._strumLine = strumLine
end

function Note:getAttachedConductor()
    return self._attachedConductor
end

---
--- @param  conductor  funkin.backend.Conductor
---
function Note:attachConductor(conductor)
    self._attachedConductor = conductor
end

function Note:wasHit()
    return self._wasHit
end

function Note:hit()
    self._wasHit = true
    if self._length > 0.0 then
        self:setVisibility(false)
    else
        self:kill()
    end
end

function Note:wasMissed()
    return self._missed
end

function Note:miss()
    self._missed = true
    self:setAlpha(0.3)
    
    self._sustain:getBody():setAlpha(0.3)
    self._sustain:getTail():setAlpha(0.3)
end

function Note:getSustain()
    return self._sustain
end

---
--- @param  strumLine  funkin.gameplay.StrumLine  The strumline that this note belongs to.
--- @param  time       number                     The time at which the note should spawn. (in milliseconds)
--- @param  lane       integer                    The lane that the note will spawn in. (from 0 to 4)
--- @param  length     number                     The length of the note. (in milliseconds)
--- @param  type       string                     The type of the note.
--- @param  skin       string                     The skin of the note.
---
function Note:setup(strumLine, time, lane, length, type, skin)
    self:setUpdateMode(_inherit_)
    self:setVisibility(true)
    self:setAlpha(1.0)
    self:setTint(Color.WHITE)

    local json = NoteSkin.get(skin) --- @type funkin.backend.data.NoteSkin?
    if json.notes.antialiasing ~= nil then
        self:setAntialiasing(json.notes.antialiasing)
    else
        self:setAntialiasing(true)
    end
    self:setStrumLine(strumLine)
    self:setPosition(-999999, -999999)

    self:setTime(time)
    self:setLength(length)
    self:setType(type)

    self:setSkin(skin)
    self:setLaneID(lane)

    self._wasHit = false
    self._missed = false
    
    local sustain = self._sustain --- @type funkin.gameplay.Sustain
    sustain:setup(self, skin)
    
    local sustainGroup = strumLine.sustains --- @type chip.graphics.CanvasLayer
    if not sustainGroup:contains(sustain) then
        sustainGroup:add(sustain)
    end
end

function Note:updatePosition(songPos)
    local strumLine = self._strumLine
    local receptor = strumLine.receptors:getMembers()[self._lane + 1]

    local scrollSpeed = strumLine:getScrollSpeed() / Engine.timeScale
    local absScrollSpeed = abs(scrollSpeed)
    
    local scrollMult = (scrollSpeed < 0.0 and -1.0 or 1.0)
    if strumLine:isDownscroll() then
        scrollMult = -scrollMult
    end
    self:setX(receptor:getX())
    self:setY(receptor:getY() + (0.45 * (self._time - songPos) * absScrollSpeed * scrollMult))
    
    local receptor = strumLine.receptors:getMembers()[self:getLaneID() + 1]
    local conductor = self._attachedConductor --- @type funkin.backend.Conductor

    local wasHit = self._wasHit and not self._missed
    local sexo = wasHit and 0.45 * (conductor:getTime() - self._time) * absScrollSpeed or 0.0
    
    local sustain = self._sustain --- @type funkin.gameplay.Sustain
    local calcHeight = max((0.45 * (self._length - conductor:getStepCrotchet()) * absScrollSpeed) - sexo)

    sustain:setPosition(
        self:getX(),
        (wasHit and receptor:getY() or self:getY()) + (scrollMult < 0.0 and -calcHeight or 0.0) + (receptor._initialHeight * 0.5)
    )
    sustain:setLength(calcHeight)
end

function Note:canBeHit()
    local conductor = self._attachedConductor
    return abs(self:getTime() - conductor:getTime()) < conductor.safeZoneOffset * 1.2
end

function Note:isTooLate()
    local conductor = self._attachedConductor
    return (self:getTime() - conductor:getTime()) < -conductor.safeZoneOffset
end

function Note:update(dt)
    self:updatePosition(self._attachedConductor:getTime())
    Note.super.update(self, dt)
end

function Note:free()
    if self._sustain then
        if not self._sustain:getParent() then
            self._sustain:free()
        end
        self._sustain = nil
    end
    Note.super.free(self)
end

return Note