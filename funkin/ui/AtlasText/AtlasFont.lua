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
--- @class funkin.ui.AtlasText.AtlasFont
---
local AtlasFont = {
    offset = nil, --- @type {x: number, y: number}
    fps = nil, --- @type number?
    
    scale = nil, --- @type number?
    lineHeight = nil, --- @type number?

    noLowerCase = nil, --- @type boolean?
    glyphs = nil, --- @type table<string, funkin.ui.AtlasText.AtlasFontGlyph>
}
return AtlasFont