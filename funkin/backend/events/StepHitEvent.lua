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

local CancellableEvent = require("funkin.backend.events.CancellableEvent") --- @type funkin.backend.events.CancellableEvent

---
--- @class funkin.backend.events.StepHitEvent : funkin.backend.events.CancellableEvent
---
local StepHitEvent = CancellableEvent:extend("StepHitEvent", ...)

function StepHitEvent:constructor(step)
    StepHitEvent.super.constructor(self)

    ---
    --- @protected
    ---
    self._step = step --- @type integer
end

function StepHitEvent:getStep()
    return self._step
end

return StepHitEvent