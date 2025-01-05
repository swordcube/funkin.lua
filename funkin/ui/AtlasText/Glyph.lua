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

local tblContains = table.contains

---
--- @class funkin.ui.AtlasText.Glyph : chip.graphics.Sprite
---
local Glyph = Sprite:extend("Glyph", ...)
Glyph.allLetters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

function Glyph:constructor(x, y, parent, character)
    Glyph.super.constructor(self, x, y)

    self._parent = parent --- @type funkin.ui.AtlasText
    self._character = character --- @type string

    local p = self._parent

    local fontData = p:getFontData()
    if fontData.noLowerCase then
        character = character:upper()
    end
    self:setFrames(Paths.getSparrowAtlas(p:getFont(), "images/fonts"))

    local prefix = character .. "0"
    if not fontData.noLowerCase and tblContains(Glyph.allLetters, character:upper()) then
        local lowercase = character:upper() ~= character
        prefix = (lowercase and character:lower() .. " lowercase" or character:upper() .. " capital") .. "0"
    end
    local glyphData = fontData.glyphs[character]

    if glyphData and glyphData.visible == false then
        self:kill()
        return
    end
    if glyphData and glyphData.prefix then
        prefix = glyphData.prefix .. "0"
    end
    self.animation:addByPrefix("idle", prefix, fontData.fps or 24)
    
    if self.animation:exists("idle") then
        self.animation:play("idle")
    end
end

function Glyph:getCharacter()
    return self._character
end

function Glyph:updateOffset()
    local fontData = self._parent:getFontData()
    local glyphData = fontData.glyphs[self._character]

    local fx = fontData.offset.x
	local fy = fontData.offset.y

	local ox = (glyphData and glyphData.offset) and glyphData.offset.x or 0.0
	local oy = ((glyphData and glyphData.offset) and glyphData.offset.y or 0.0) - (110 - self:getFrameHeight())

	self.frameOffset:set(ox - fx, oy - fy)
end

return Glyph