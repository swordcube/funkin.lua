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
--- @class funkin.backend.Constants
---
local Constants = {}

---
--- The version number for this copy of funkin.lua.
---
Constants.ENGINE_VERSION = "0.1.0"

---
--- The file extension used for loading image files.
---
Constants.IMAGE_EXT = "png"

---
--- The file extension used for loading audio files.
---
Constants.SOUND_EXT = "ogg"

---
--- The default health icon used as fallback.
---
Constants.DEFAULT_HEALTH_ICON = "face"

---
--- The commit hash for this copy of funkin.lua.
--- 
--- If this value is `nil`, then this is a release copy
--- of the engine.
---
Constants.COMMIT_HASH = nil

---
--- A list of every available note direction.
---
Constants.NOTE_DIRECTIONS = {"left", "down", "up", "right"}

return Constants