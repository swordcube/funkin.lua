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
--- @class funkin.backend.song.chart.NoteData
---
local NoteData = {
    ---
    --- The time that the note should be hit at. (in milliseconds)
    ---
    time = nil, --- @type number

    ---
    --- The lane that the note should be hit on.
    --- 
    --- 0 to 3 represents the opponent, 4 to 7 represents the player.
    ---
    lane = nil, --- @type integer

    ---
    --- The length of the note. (in milliseconds)
    ---
    length = nil, --- @type number

    ---
    --- The type of note to spawn.
    ---
    type = nil, --- @type string
}
return NoteData