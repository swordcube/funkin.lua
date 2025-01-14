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

local Transition = require("funkin.ui.transition.Transition") --- @type funkin.ui.transition.Transition

---
--- @class funkin.ui.transition.GradientSwipe : funkin.ui.transition.Transition
---
local GradientSwipe = Transition:extend("GradientSwipe", ...)

GradientSwipe.isBlocking = false

function GradientSwipe:enterTransition()
    GradientSwipe.isBlocking = (Engine.currentScene:getUpdateMode() == "inherit")
    if GradientSwipe.isBlocking then
        Engine.currentScene:setUpdateMode("disabled")
        TweenManager.global:pause()
        TimerManager.global:pause()
    end
    local blackScreen = Sprite:new() --- @type chip.graphics.Sprite
    blackScreen:makeSolid(Engine.gameWidth, Engine.gameHeight, Color.BLACK)
    blackScreen:screenCenter("xy")
    blackScreen:setY(blackScreen:getY() - (blackScreen:getHeight() * 2))
    self:add(blackScreen)

    local gradientSpr = Sprite:new() --- @type chip.graphics.Sprite
    gradientSpr:loadTexture(Paths.image("transitionSpr", "images/menus"))
    gradientSpr:setGraphicSize(Engine.gameWidth, Engine.gameHeight)
    gradientSpr:screenCenter("xy")
    gradientSpr:setY(gradientSpr:getY() - gradientSpr:getHeight())
    self:add(gradientSpr)

    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(blackScreen, "y",blackScreen:getY() + (blackScreen:getHeight() * 2), 0.7):setEase(Ease.sineOut)
    t:tweenProperty(gradientSpr, "y", gradientSpr:getY() + (gradientSpr:getHeight() * 2), 0.7):setEase(Ease.sineOut)
    t:setCompletionCallback(function(_)
        self:finish()
    end)
end

function GradientSwipe:exitTransition()
    local prevUpdateMode = Engine.currentScene:getUpdateMode()
    if GradientSwipe.isBlocking and prevUpdateMode == "inherit" then
        GradientSwipe.isBlocking = true
        Engine.currentScene:setUpdateMode("disabled")
        
        TweenManager.global:pause()
        TimerManager.global:pause()
    end
    local blackScreen = Sprite:new() --- @type chip.graphics.Sprite
    blackScreen:makeSolid(Engine.gameWidth, Engine.gameHeight, Color.BLACK)
    blackScreen:screenCenter("xy")
    self:add(blackScreen)
    
    local gradientSpr = Sprite:new() --- @type chip.graphics.Sprite
    gradientSpr:loadTexture(Paths.image("transitionSpr", "images/menus"))
    gradientSpr:setGraphicSize(Engine.gameWidth, Engine.gameHeight)
    gradientSpr:screenCenter("xy")
    gradientSpr.flipY = true
    gradientSpr:setY(gradientSpr:getY() - gradientSpr:getHeight())
    self:add(gradientSpr)
    
    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(blackScreen, "y",blackScreen:getY() + (blackScreen:getHeight() * 2), 0.7):setEase(Ease.sineOut)
    t:tweenProperty(gradientSpr, "y", gradientSpr:getY() + (gradientSpr:getHeight() * 2), 0.7):setEase(Ease.sineOut)
    t:setCompletionCallback(function(_)
        local prevUpdateMode = Engine.currentScene:getUpdateMode()
        if GradientSwipe.isBlocking and prevUpdateMode ~= "disabled" then
            Engine.currentScene:setUpdateMode("inherit")

            TweenManager.global:resume()
            TimerManager.global:resume()
        end
        GradientSwipe.isBlocking = false
        self:finish()
    end)
end

return GradientSwipe