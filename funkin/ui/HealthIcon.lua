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

local lerp = math.lerp

---
--- @type funkin.backend.utils.TrackingSprite
---
local TrackingSprite = require("funkin.backend.utils.TrackingSprite")

---
--- @type funkin.backend.data.CharacterData
---
local CharacterData = require("funkin.backend.data.CharacterData")

---
--- @type funkin.backend.data.HealthIconData
---
local HealthIconData = require("funkin.backend.data.HealthIconData")

---
--- @class funkin.ui.HealthIcon : funkin.backend.utils.TrackingSprite
---
local HealthIcon = TrackingSprite:extend("HealthIcon", ...)

HealthIcon.WINNING_THRESHOLD = 0.8
HealthIcon.LOSING_THRESHOLD = 0.2
HealthIcon.ICON_SPEED = 0.15

HealthIcon.HEALTH_ICON_SIZE = 150
HealthIcon.PIXEL_ICON_SIZE = 32

HealthIcon.BOP_AMOUNT = 0.2

---
--- @param  character  string
--- @param  isPlayer   boolean?
---
function HealthIcon:constructor(character, isPlayer)
    HealthIcon.super.constructor(self)

    isPlayer = isPlayer or false

    ---
    --- The ID of the character that this icon represents.
    --- 
    --- @type string
    ---
    self.characterID = nil

    ---
    --- Whether this health icon represents the player.
    ---
    --- @type boolean
    ---
    self.isPlayer = isPlayer

    ---
    --- Whether this health icon is in legacy style.
    ---
    --- @type boolean
    ---
    self.isLegacyStyle = false

    ---
    --- Whether this health icon is in pixel style.
    ---
    --- @type boolean
    ---
    self.isPixel = false

    ---
    --- The initial X and Y scale of this health icon.
    --- 
    --- @type chip.math.Point
    ---
    self.size = Point:new(1, 1)

    ---
    --- The current health of this icon.
    --- 
    --- @type number
    ---
    self.health = 0.5

    ---
    --- @protected
    --- @type string
    ---
    self._characterID = nil

    ---
    --- @protected
    --- @type chip.tweens.Tween
    ---
    self._bopTween = nil

    self.__initializing = false
    self:set_characterID(character or "face")
end

---
--- @param  name      string
--- @param  fallback  string?
--- @param  restart   boolean?
---
function HealthIcon:playIconAnim(name, fallback, restart)
    restart = restart or false
    if self.animation:exists(name) then
        self.animation:play(name, restart, false, 1)
        return
    end
    if fallback and self.animation:exists(fallback) then
        self.animation:play(fallback, restart, false, 1)
    end
end

function HealthIcon:update(dt)
    self:_updateHealth(self.health)
    HealthIcon.super.update(self, dt)
end

function HealthIcon:bop()
    if self._bopTween then
        self._bopTween:free()
    end
    local finalSize = 0.0
    if self:getWidth() > self:getHeight() then
        self:setGraphicSize((HealthIcon.HEALTH_ICON_SIZE * self.size.x) * (1 + HealthIcon.BOP_AMOUNT), 0)
        finalSize = HealthIcon.HEALTH_ICON_SIZE * self.size.x
    else
        self:setGraphicSize(0, (HealthIcon.HEALTH_ICON_SIZE * self.size.y) * (1 + HealthIcon.BOP_AMOUNT))
        finalSize = HealthIcon.HEALTH_ICON_SIZE * self.size.y
    end
    self._bopTween = Tween:new() --- @type chip.tweens.Tween
    self._bopTween:tweenProperty(self, "scale", Point:new(finalSize / self:getFrameWidth(), finalSize / self:getFrameHeight()), HealthIcon.ICON_SPEED, Ease.sineOut)
    self._bopTween:setCompletionCallback(function(_)
        self._bopTween = nil
    end)
end

-----------------------
--- [ Private API ] ---
-----------------------

---
--- @protected
--- @param  charData     funkin.backend.data.CharacterData
---
function HealthIcon:_isNewSpritesheet(charData)
    return charData and File.exists(Paths.xml("images/" .. charData.healthIcon.atlasPath))
end

---
--- @protected
--- @param  characterID  string
--- @param  charData     funkin.backend.data.CharacterData
---
function HealthIcon:_correctCharacterID(characterID, charData)
    -- TODO: support mods
    if not characterID then
        characterID = Constants.DEFAULT_HEALTH_ICON
    end
    if characterID:contains("-") and (not File.exists(Paths.image("game/icons/" .. characterID)) and (charData and not File.exists(Paths.image(charData.healthIcon.atlasPath)))) then
        characterID = characterID:sub(1, characterID:indexOf("-"))
        charData = CharacterData.get(characterID)
    end
    if not File.exists(Paths.image("game/icons/" .. characterID)) and (charData and not File.exists(Paths.image(charData.healthIcon.atlasPath))) then
        Log.warn(nil, nil, nil, "Health icon for " .. characterID .. " doesn't exist!")
        return Constants.DEFAULT_HEALTH_ICON
    end
    return characterID
end

---
--- @protected
---
function HealthIcon:_loadAnimationNew()
    self.animation:addByPrefix("idle", "idle", 24, true)
    self.animation:addByPrefix("winning", "winning", 24, true)
    self.animation:addByPrefix("losing", "losing", 24, true)

    self.animation:addByPrefix("toWinning", "toWinning", 24, true)
    self.animation:addByPrefix("toLosing", "toLosing", 24, true)

    self.animation:addByPrefix("fromWinning", "fromWinning", 24, true)
    self.animation:addByPrefix("fromLosing", "fromLosing", 24, true)
end

---
--- @protected
---
function HealthIcon:_loadAnimationOld()
    self.animation:add("idle", {1}, 24, false)
    self.animation:add("losing", {2}, 24, false)
    if self.animation:getNumFrames() >= 3 then
        self.animation:add("winning", {3}, 24, false)
    end
end

---
--- @protected
---
function HealthIcon:_updateHealth(health)
    local animName = self.animation:getCurrentAnimationName()
    if animName == "idle" then
        if health < HealthIcon.LOSING_THRESHOLD then
            self:playIconAnim("toLosing", "losing")
        
        elseif health > HealthIcon.WINNING_THRESHOLD then
            self:playIconAnim("toWinning", "winning")

        else
            self:playIconAnim("idle")
        end
    
    elseif animName == "winning" then
        if health < HealthIcon.WINNING_THRESHOLD then
            self:playIconAnim("fromWinning", "idle")
        else
            self:playIconAnim("winning", "idle")
        end
    
    elseif animName == "losing" then
        if health > HealthIcon.LOSING_THRESHOLD then
            self:playIconAnim("fromLosing", "idle")
        else
            self:playIconAnim("losing", "idle")
        end
    
    elseif animName == "toLosing" then
        if self.animation.finished then
            self:playIconAnim("losing", "idle")
        end
    
    elseif animName == "toWinning" then
        if self.animation.finished then
            self:playIconAnim("winning", "idle")
        end
    
    elseif animName == "fromLosing" or animName == "fromWinning" then
        if self.animation.finished then
            self:playIconAnim("idle")
        end
    else
        self:playIconAnim("idle")
    end
end

---
--- @protected
--- @param  characterID  string
---
function HealthIcon:_loadCharacter(characterID)
    local charData = CharacterData.get(characterID)
    characterID = self:_correctCharacterID(characterID, charData)

    isPixel = (charData and charData.healthIcon) and charData.healthIcon.isPixel or false
    isLegacyStyle = not self:_isNewSpritesheet(charData)

    if not isLegacyStyle then
        self.frames = Paths.getSparrowAtlas(charData.healthIcon.atlasPath)
        self:_loadAnimationNew()
    else
        local sizeX = (charData and charData.healthIcon.gridSize and charData.healthIcon.gridSize.x) and charData.healthIcon.gridSize.x or (isPixel and HealthIcon.PIXEL_ICON_SIZE or HealthIcon.ICON_SIZE)
        local sizeY = (charData and charData.healthIcon.gridSize and charData.healthIcon.gridSize.y) and charData.healthIcon.gridSize.y or (isPixel and HealthIcon.PIXEL_ICON_SIZE or HealthIcon.ICON_SIZE)

        local fallbackCharPath = "game/icons/" .. characterID
        local fallbackFacePath = "game/icons/face"

        self:loadTexture(Paths.image(charData and charData.healthIcon.atlasPath or (File.fileExists(Paths.image(fallbackCharPath)) and fallbackCharPath or fallbackFacePath)), true, sizeX, sizeY)
        self:_loadAnimationOld()
    end
    self:setAntialiasing(not isPixel)

    local leScale = (charData and charData.healthIcon) and charData.healthIcon.scale or 1.0
    self.size:set(leScale, leScale)
    self:setGraphicSize(HealthIcon.HEALTH_ICON_SIZE * self.size.x, HealthIcon.HEALTH_ICON_SIZE * self.size.y)

    self.flipX = (charData and charData.healthIcon and charData.healthIcon.flip) and charData.healthIcon.flip.x or false
    self.flipY = (charData and charData.healthIcon and charData.healthIcon.flip) and charData.healthIcon.flip.y or false

    self.offset:set(
        (self:getWidth() - self:getFrameWidth()) * -0.5,
        (self:getHeight() - self:getFrameHeight()) * -0.5
    )
    self.frameOffset:set(
        (charData and charData.healthIcon and charData.healthIcon.offset) and charData.healthIcon.offset.x or 0.0,
        (charData and charData.healthIcon and charData.healthIcon.offset) and charData.healthIcon.offset.y or 0.0
    )
end

---
--- @protected
--- @param  val  string
---
function HealthIcon:set_characterID(val)
    if self._characterID ~= val then
        self._characterID = val
        self:_loadCharacter(self._characterID)
    end
    return self._characterID
end

return HealthIcon