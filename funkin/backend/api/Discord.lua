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
--- @class funkin.backend.api.DiscordPresenceData
---
local DiscordPresenceData = {
    state = nil, --- @type string
    details = nil, --- @type string?

    largeImageKey = nil, --- @type string?
    largeImageText = nil, --- @type string?

    smallImageKey = nil, --- @type string?
    smallImageText = nil, --- @type string?
}

local DiscordRPC = require("funkin.backend.libs.DiscordRPC") --- @type funkin.libs.DiscordRPC

---
--- @class funkin.api.Discord
---
local Discord = {}

---
--- @protected
--- @type number
---
Discord._updateTimer = 0.0

function Discord.init()
    DiscordRPC.initialize("1290899086911733771", true)
    DiscordRPC.ready = function(userID, username, discriminator, avatar)
        print("Connected as " .. username .. " (" .. userID .. ")")
    end
    Engine.preUpdate:connect(function()
        DiscordRPC.runCallbacks()
    end)
    Engine.onQuit:connect(function()
        DiscordRPC.shutdown()
    end)
end

---
--- @param  data  funkin.backend.api.DiscordPresenceData
---
function Discord.changePresence(data)
    DiscordRPC.updatePresence({
        state = data.state,
        details = data.details,

        largeImageKey = data.icon and data.icon or "icon",
        largeImageText = data.largeImageText and data.largeImageText or "funkin.lua",
        
        smallImageKey = data.smallImageKey,
        smallImageText = data.smallImageText
    })
end

return Discord