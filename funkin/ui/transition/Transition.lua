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
--- @class funkin.ui.transition.Transition : chip.graphics.CanvasLayer
---
local Transition = CanvasLayer:extend("Transition", ...)

Transition.instance = nil --- @type funkin.ui.transition.Transition
Transition.currentType = nil --- @type funkin.ui.transition.Transition

---
--- @protected
---
Transition._inAllowed = true

function Transition.init()
    Transition.currentType = require("funkin.ui.transition.GradientSwipe")
    Engine.preSceneSwitch:connect(function()
        if Transition._inAllowed then
            Engine.preSceneSwitch:cancel()
            Transition.show("in")
        end
    end)
end

---
--- @param  state  "in"|"out"
---
function Transition.show(state)
    if Transition.instance then
        Transition.instance:free()
        Transition.instance = nil
    end
    if state == "in" then
        Engine.currentScene:add(Transition.currentType:new("in"))
    else
        Engine.currentScene:add(Transition.currentType:new("out"))
    end
end

function Transition:constructor(state)
    Transition.super.constructor(self)
    Transition.instance = self

    ---
    --- @protected
    --- @type "in"|"out"
    ---
    self._state = state or "out"

    if self._state == "in" then
        self:enterTransition()
    else
        self:exitTransition()
    end
end

function Transition:getState()
    return self._state
end

function Transition:enterTransition()
end

function Transition:exitTransition()
end

function Transition:finish()
    if self._state == "in" then
        if Engine._requestedScene then
            Transition._inAllowed = false
            self._state = "out"

            Engine.postSceneSwitch:connect(function()
                Transition.show("out")
                Transition._inAllowed = true
            end, nil, true)
            Engine._switchScene()
        else
            Transition.show("out")
        end
    else
        Transition.instance = nil
    end
    self:free()
end

return Transition