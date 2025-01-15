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
--- @class funkin.ui.Checkbox : chip.graphics.Sprite
---
local Checkbox = Sprite:extend("Checkbox", ...)

function Checkbox:constructor(x, y)
    Checkbox.super.constructor(self, x, y)

    self:setFrames(Paths.getSparrowAtlas("checkbox", "images/menus/options"))
    self.animation:addByPrefix("unselected", "unselected", 24, false)
    self.animation:setOffset("unselected", 8, 8)

    self.animation:addByPrefix("selecting", "selecting", 24, false)
    self.animation:setOffset("selecting", 50, 88)

    self.scale:set(0.8, 0.8)
    self:unselect()
end

function Checkbox:unselect()
    self.animation:play("unselected", true)
end

function Checkbox:select()
    self.animation:play("selecting", true)
end

return Checkbox