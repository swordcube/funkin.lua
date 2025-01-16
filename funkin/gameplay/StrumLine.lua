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

local NoteSkin = require("funkin.backend.data.NoteSkin") --- @type funkin.backend.data.NoteSkin

local Receptor = require("funkin.gameplay.Receptor") --- @type funkin.gameplay.Receptor
local HoldCover = require("funkin.gameplay.HoldCover") --- @type funkin.gameplay.HoldCover
local NoteSplash = require("funkin.gameplay.NoteSplash") --- @type funkin.gameplay.NoteSplash

local Note = require("funkin.gameplay.Note") --- @type funkin.gameplay.Note

---
--- @class funkin.gameplay.StrumLine : chip.graphics.CanvasLayer
---
local StrumLine = CanvasLayer:extend("StrumLine", ...)

function StrumLine:constructor(x, y, downscroll, skin)
    StrumLine.super.constructor(self, x, y, downscroll, skin)

    ---
    --- @protected
    ---
    self._downscroll = downscroll --- @type boolean

    ---
    --- @protected
    ---
    self._skin = skin or "default" --- @type string

    ---
    --- @protected
    ---
    self._attachedNotes = {} --- @type table<funkin.backend.song.chart.NoteData>

    ---
    --- @protected
    --- @type integer
    ---
    self._spawnedNotes = 0

    ---
    --- @protected
    --- @type number
    ---
    self._scrollSpeed = 1.0

    ---
    --- @protected
    --- @type integer
    ---
    self._curSplash = 1

    ---
    --- @protected
    --- @type number?
    ---
    self._forceSongPos = nil

    ---
    --- @protected
    --- @type table<funkin.gameplay.Character>
    ---
    self._characters = {}

    if Options.sustainLayering == "Below" then
        self.sustains = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
        self:add(self.sustains)
    end
    self.receptors = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.receptors)

    local json = NoteSkin.get(self._skin) --- @type funkin.backend.data.NoteSkin?
    for i = 0, 3 do
        local receptor = Receptor:new((i - 2) * json.receptors.spacing, 0, i, self._skin) --- @type funkin.gameplay.Receptor
        receptor:setPosition(
            receptor:getX() - ((receptor:getFrameWidth() - receptor:getWidth()) * 0.5),
            receptor:getY() - ((receptor:getFrameHeight() - receptor:getHeight()) * 0.5)
        )
        self.receptors:add(receptor)
    end
    if Options.sustainLayering == "Above" then
        self.sustains = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
        self:add(self.sustains)
    end
    self.notes = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.notes)

    self.holdCovers = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.holdCovers)

    self.splashes = CanvasLayer:new() --- @type chip.graphics.CanvasLayer
    self:add(self.splashes)

    for i = 1, 16 do
        local note = Note:new() --- @type funkin.gameplay.Note
        note:setup(self, 0.0, (i - 1) % 4, 0.0, "Default", self._skin)
        note:kill()
        self.notes:add(note)
        
        local sustain = note:getSustain() --- @type funkin.gameplay.Sustain
        sustain:kill()
        self.sustains:add(sustain)
    end
    for i = 1, 4 do
        local holdCover = HoldCover:new(0, 0, (i - 1) % 4, self._skin) --- @type funkin.gameplay.HoldCover
        holdCover:setup(self, (i - 1) % 4, self._skin)
        holdCover:kill()
        self.holdCovers:add(holdCover)
    end
    for i = 1, 8 do
        local splash = NoteSplash:new(0, 0, (i - 1) % 4, self._skin) --- @type funkin.gameplay.NoteSplash
        splash:setup(self, (i - 1) % 4, self._skin)
        splash:kill()
        self.splashes:add(splash)
    end
end

function StrumLine:isDownscroll()
    return self._downscroll
end

function StrumLine:setDownscroll(downscroll)
    self._downscroll = downscroll
end

function StrumLine:getAttachedNotes()
    return self._attachedNotes
end

---
--- @param  notes  table<funkin.backend.song.chart.NoteData>
---
function StrumLine:attachNotes(notes)
    self._attachedNotes = notes
    table.sort(self._attachedNotes, function(a, b)
        return a.time < b.time
    end)
end

function StrumLine:getSkin()
    return self._skin
end

---
--- @param  skin  string
---
function StrumLine:setSkin(skin)
    self._skin = skin

    local members = self.receptors:getMembers()
    for i = 1, self.receptor:getLength() do
        local receptor = members[i] --- @type funkin.gameplay.Receptor
        receptor:setSkin(skin)
    end
    local noteMembers = self.notes:getMembers()
    for i = 1, self.notes:getLength() do
        local note = noteMembers[i] --- @type funkin.gameplay.Note
        note:setSkin(skin)
    end
end

function StrumLine:getSpawnedNotes()
    return self._spawnedNotes
end

function StrumLine:resetSpawnedNotes()
    self._spawnedNotes = 1
end

function StrumLine:getScrollSpeed()
    return self._scrollSpeed
end

---
--- @param  scrollSpeed  number
---
function StrumLine:setScrollSpeed(scrollSpeed)
    self._scrollSpeed = scrollSpeed
end

function StrumLine:getCharacters()
    return self._characters
end

---
--- @param  characters  table<funkin.gameplay.Character>
---
function StrumLine:setCharacters(characters)
    self._characters = characters
end

return StrumLine