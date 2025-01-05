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
--- @class funkin.backend.utils.TrackingSprite : chip.graphics.Sprite
---
local TrackingSprite = Sprite:extend("TrackingSprite", ...)

function TrackingSprite:constructor(x, y)
    TrackingSprite.super.constructor(self, x, y)

    ---
    --- The offset in X and Y to the tracked object.
    ---
    --- @type chip.math.Point
    ---
    self.trackingOffset = Point:new(10.0, -30.0)

    ---
    --- The sprite we are tracking.
    ---
    --- @type chip.graphics.Sprite?
    ---
    self.tracked = nil

    ---
    --- Tracking mode (or direction) of this sprite.
    ---
    --- @type funkin.backend.utils.TrackingMode
    ---
    self.trackingMode = "right"

    ---
    --- Whether or not to copy the alpha from
	--- the sprite being tracked.
    ---
    --- @type boolean
    ---
    self.copyAlpha = true

    ---
    --- Whether or not to copy the visibility from
	--- the sprite being tracked.
    ---
    --- @type boolean
    ---
    self.copyVisibility = true
end

function TrackingSprite:update(dt)
    if self.tracked then
        if self.trackingMode == "right" then
            self:setPosition(self.tracked:getX() + self.tracked:getWidth() + self.trackingOffset.x, self.tracked:getY() + self.trackingOffset.y)
        
        elseif self.trackingMode == "left" then
            self:setPosition(self.tracked:getX() + self.trackingOffset.x, self.tracked:getY() + self.trackingOffset.y)
        
        elseif self.trackingMode == "up" then
            self:setPosition(self.tracked:getX() + (self.tracked:getWidth() * 0.5) + self.trackingOffset.x, self.tracked:getY() - self:getHeight() + self.trackingOffset.y)
        
        elseif self.trackingMode == "down" then
            self:setPosition(self.tracked:getX() + (self.tracked:getWidth() * 0.5) + self.trackingOffset.x, self.tracked:getY() + self.tracked:getHeight() + self.trackingOffset.y)
        end
        if self.copyAlpha then
            self:setAlpha(self.tracked:getAlpha())
        end
        if self.copyVisibility then
            self:setVisibility(self.tracked:isVisible())
        end
    end
    TrackingSprite.super.update(self, dt)
end

return TrackingSprite