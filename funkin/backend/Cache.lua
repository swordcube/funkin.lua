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
--- @class funkin.backend.Cache
---
local Cache = {}

---
--- @type table<string, chip.animation.frames.FrameCollection>
---
Cache.atlasCache = {}
setmetatable(Cache.atlasCache, {
    __newindex = function(t, k, v)
        if v:is(RefCounted) then
            v:reference()
        end
        rawset(t, k, v)
    end
})

---
--- @type table<string, funkin.ui.AtlasText.AtlasFont>
---
Cache.atlasFontCache = {}

---
--- @type table<string, funkin.backend.data.NoteSkin>
---
Cache.noteSkinCache = {}

---
--- @type table<string, funkin.backend.data.UISkin>
---
Cache.uiSkinCache = {}

function Cache.clear()
    for _, value in pairs(Cache.atlasCache) do
        value:unreference()
    end
    Cache.atlasCache = {}
    Cache.atlasFontCache = {}
    
    Cache.noteSkinCache = {}
    Cache.uiSkinCache = {}
end

return Cache