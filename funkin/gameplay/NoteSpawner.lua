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

---@diagnostic disable: invisible

local Note = require("funkin.gameplay.Note") --- @type funkin.gameplay.Note

---
--- @class funkin.gameplay.NoteSpawner : chip.core.Actor
---
local NoteSpawner = Actor:extend("NoteSpawner", ...)

function NoteSpawner:constructor()
    NoteSpawner.super.constructor(self)

    ---
    --- @protected
    ---
    self._attachedConductor = Conductor.instance --- @type funkin.backend.Conductor

    ---
    --- @protected
    ---
    self._attachedStrumLines = {} --- @type table<funkin.gameplay.StrumLine>
end

function NoteSpawner:getAttachedStrumLines()
    return self._attachedStrumLines
end

---
--- @param  strumLines  table<funkin.gameplay.StrumLine>
---
function NoteSpawner:attachStrumLines(strumLines)
    self._attachedStrumLines = strumLines
end

function NoteSpawner:getAttachedConductor()
    return self._attachedConductor
end

function NoteSpawner:attachConductor(conductor)
    self._attachedConductor = conductor
end

function NoteSpawner:update(dt)
    local timeScale = Engine.timeScale
    for i = 1, #self._attachedStrumLines do
        local strumLine = self._attachedStrumLines[i] --- @type funkin.gameplay.StrumLine
        local attachedNotes = strumLine._attachedNotes --- @type table<funkin.backend.song.chart.NoteData>
        
        local attachedNotesCount = #attachedNotes
        if attachedNotesCount == 0 then
            goto continue
        end
        while strumLine._spawnedNotes < attachedNotesCount and attachedNotes[strumLine._spawnedNotes + 1].time < self._attachedConductor:getTime() + (1500 / (strumLine:getScrollSpeed() / timeScale)) do
            strumLine._spawnedNotes = strumLine._spawnedNotes + 1
            local noteData = attachedNotes[strumLine._spawnedNotes] --- @type funkin.backend.song.chart.NoteData
            
            local note = strumLine.notes:recycle(Note) --- @type funkin.gameplay.Note
            note:attachConductor(self._attachedConductor)
            note:setup(strumLine, noteData.time, noteData.lane, noteData.length, noteData.type, strumLine:getSkin())
        end
        ::continue::
    end
end

return NoteSpawner