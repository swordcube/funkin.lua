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
--- @class funkin.ui.options.OptionData
---
local OptionData = {
    name = nil, --- @type string
    description = nil, --- @type string

    id = nil, --- @type string
}

---
--- @class funkin.ui.options.Option : chip.graphics.CanvasLayer
---
local Option = CanvasLayer:extend("Option", ...)

---
--- @param  data  funkin.ui.options.OptionData
---
function Option:constructor(data)
    Option.super.constructor(self)

    self.selected = false

    ---
    --- @protected
    --- @type funkin.ui.options.OptionData
    ---
    self._data = data
end

function Option:getData()
    return self._data
end

function Option:select()
end

function Option:unselect()
end

return Option