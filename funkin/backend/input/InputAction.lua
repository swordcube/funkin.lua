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