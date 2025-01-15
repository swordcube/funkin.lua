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
--- @class funkin.backend.input.InputAction
---
local InputAction = Class:extend("InputAction", ...)

-- TODO: store gamepad shit in here alongside keys

function InputAction:constructor(id, defaultKeys)
    ---
    --- The ID of this action in save data.
    ---
    --- @type string
    ---
    self.id = id

    ---
    --- The keys registered to this action.
    --- 
    --- @type table<string>
    ---
    self.keys = {}

    if not Controls._save.data[id] then
        self.keys = defaultKeys
        local newAction = {
            keys = self.keys
        }
        Controls._save.data[id] = newAction
    else
        local action = Controls._save.data[id]
        self.keys = action.keys or defaultKeys
    end
end

---
--- @param  state  chip.input.InputState
---
--- @return boolean
---
function InputAction:check(state)
    for i = 1, #self.keys do
        local key = self.keys[i] --- @type string
        if state == InputState.JUST_PRESSED and Input.wasKeyJustPressed(key) then
            return true
        end
        if state == InputState.PRESSED and Input.isKeyPressed(key) then
            return true
        end
        if state == InputState.JUST_RELEASED and Input.wasKeyJustReleased(key) then
            return true
        end
    end
    return false
end

return InputAction