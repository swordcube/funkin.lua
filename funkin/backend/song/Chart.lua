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

local abs = math.abs

local tblSort = table.sort
local tblInsert = table.insert

local SongMetadata = require("funkin.backend.song.SongMetadata") --- @type funkin.backend.song.SongMetadata

---
--- @class funkin.backend.song.Chart
---
local Chart = {}

---
--- @param  song        string
--- @param  difficulty  string
--- @param  mod?        string
---
--- @return funkin.backend.song.chart.ChartData
---
function Chart.load(song, difficulty, mod)
    local chart = Json.parse(File.read(Paths.chart(song, difficulty, nil, mod))) --- @type funkin.backend.song.chart.ChartData
    chart.meta = SongRegistry.instance:getEntry(song, mod)

    local uniqueNotes = {} --- @type table<funkin.backend.song.chart.NoteData>
    local chartNotes = chart.notes --- @type table<funkin.backend.song.chart.NoteData>
    tblSort(chartNotes, function(a, b)
        return a.time < b.time
    end)
    for i = 1, #chartNotes do
        local note = chartNotes[i] --- @type funkin.backend.song.chart.NoteData
        local isStacked = false
        for j = 1, #uniqueNotes do
            local uniqueNote = uniqueNotes[j]
            if note.lane == uniqueNote.lane and note.type == uniqueNote.type and abs(note.time - uniqueNote.time) < 2 then
                isStacked = true
                break
            end
        end
        if not isStacked then
            tblInsert(uniqueNotes, note)
        end
    end
    chart.notes = uniqueNotes
    tblSort(chart.events, function(a, b)
        return a.time < b.time
    end)
    return chart
end

return Chart