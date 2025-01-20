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

local CharacterData = require("funkin.backend.data.CharacterData") --- @type funkin.backend.data.CharacterData

---
--- @class funkin.gameplay.Character : chip.graphics.Sprite
---
local Character = Sprite:extend("Character", ...)

function Character:constructor(x, y, characterID, isPlayer)
    Character.super.constructor(self, x, y)

    self._characterID = characterID
    self._isPlayer = isPlayer

    local json = CharacterData.get(characterID) --- @type funkin.backend.data.CharacterData?
    if not json then
        characterID = "bf"
        self._characterID = characterID
        
        json = CharacterData.get("bf")
    end

    ---
    --- @protected
    ---
    self._config = json --- @type funkin.backend.data.CharacterData?

    ---
    --- @protected
    ---
    self._curDanceStep = 1

    if json.atlasType == "sparrow" then
        self:setFrames(Paths.getSparrowAtlas(json.atlasPath))
        for i = 1, #json.animations do
            local animData = json.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            if animData.indices and #animData.indices > 0 then
                self.animation:addByIndices(animData.name, animData.prefix, animData.indices, animData.fps, animData.looped)
            else
                self.animation:addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped)
            end
        end
    elseif json.atlasType == "grid" then
        self:loadTexture(Paths.image(json.atlasPath), true, json.gridSize.x, json.gridSize.y)
        for i = 1, #json.animations do
            local animData = json.animations[i] --- @type funkin.backend.data.NoteSkinAnimationData
            self.animation:add(animData.name, animData.indices, animData.fps, animData.looped)
        end
    
    elseif json.atlasType == "animate" then
        -- TODO
    end
    self:dance(true)

    local offset = json.position or {x = 0, y = 0}
    self.offset:set((self:getWidth() * 0.5) + offset.x, self:getHeight() + offset.y)

    ---
    --- @protected
    ---
    self._initialWidth = self:getFrameWidth()

    ---
    --- @protected
    ---
    self._initialHeight = self:getFrameHeight()

    self.flipX = json.flip.x
    self.flipY = json.flip.y

    if isPlayer then
        self.flipX = not self.flipX
    end

    ---
    --- @protected
    ---
    self._baseFlipped = self.flipX

    ---
    --- @protected
    ---
    self._playerOffsets = json.isPlayer

    ---
    --- @protected
    ---
    self._lastSongPos = math.huge
end

function Character:update(dt)
    local mainConductor = Conductor.instance
    local singDuration = self._config.singDuration or 4.0

    local pressed = Controls.pressed
    local notesHeld = pressed.NOTE_LEFT or pressed.NOTE_DOWN or pressed.NOTE_UP or pressed.NOTE_RIGHT

    if mainConductor:getTime() > self._lastSongPos + (mainConductor:getStepCrotchet() * singDuration) and ((not self._isPlayer) or (self._isPlayer and not notesHeld)) then
        self:dance(true)
        self._lastSongPos = math.huge
    end
    Character.super.update(self, dt)
end

function Character:getConfig()
    return self._config
end

function Character:isPlayer()
    return self._isPlayer
end

function Character:dance(force)
    local danceSteps = self._config.danceSteps or {"idle"}
    self.animation:play(danceSteps[self._curDanceStep], force)
    self._curDanceStep = math.wrap(self._curDanceStep + 1, 1, #danceSteps)
end

---
--- @param  direction       "left"|"down"|"up"|"right"
--- @param  miss?           boolean
--- @param  durationOffset? number
---
function Character:sing(direction, miss, durationOffset)
    self._lastSongPos = Conductor.instance:getTime() + (durationOffset or 0.0)
    self.animation:play("sing" .. direction:upper() .. (miss and "miss" or ""), true)
end

function Character:beatHit(beat)
    local danceFrequency = self._config.danceFrequency or 2
    local animName = self.animation:getCurrentAnimationName()

    if animName and beat % danceFrequency == 0 and not animName:startsWith("sing") then
        local danceSteps = self._config.danceSteps and #self._config.danceSteps or 1
        self:dance(danceSteps == 1 and danceFrequency == 1)
    end
end

function Character:getCameraX()
    local offset = self._config.position or {x = 0, y = 0}
    local camera = self._config.camera or {x = 0, y = 0}
    return (self:getX() + (self._isPlayer and -100.0 or 150.0)) + camera.x + offset.x
end

function Character:getCameraY()
    local offset = self._config.position or {x = 0, y = 0}
    local camera = self._config.camera or {x = 0, y = 0}
    return ((self:getY() - (self._initialHeight * 0.5)) - 100) + camera.y + offset.x
end

function Character:draw()
    self:_fixOffsets()
    Character.super.draw(self)
    self:_fixOffsets()
end

--- [ PRIVATE API ] ---

---
--- @protected
---
function Character:_fixOffsets()
    if (self._isPlayer ~= self._playerOffsets) ~= (self.flipX ~= self._baseFlipped) then
        self.flipX = not self.flipX
        self.scale.x = -self.scale.x
    end
end

return Character