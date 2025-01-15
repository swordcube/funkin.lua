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

local Option = require("funkin.ui.options.Option") --- @type funkin.ui.options.Option

---
--- @class funkin.ui.options.Separator : funkin.ui.options.Option
---
local Separator = Option:extend("Separator", ...)

---
--- @param  text  string
---
function Separator:constructor(text)
    Separator.super.constructor(self)

    self.text = Text:new(0, 0, 0, text .. "\n  ", 32) --- @type chip.graphics.Text
    self.text:setFont(Paths.font("funkin.ttf"))
    self.text:setBorderSize(4)
    self.text:setBorderColor(Color.BLACK)
    self.text:setFastRendering(false)
    self.text:setAlpha(0.25)
    self:add(self.text)
end

return Separator