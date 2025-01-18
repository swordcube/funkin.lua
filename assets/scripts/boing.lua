local NoteSkin = require("funkin.backend.data.NoteSkin")

local tweens = {}

local controls = {
    Controls.list.NOTE_LEFT,
    Controls.list.NOTE_DOWN,
    Controls.list.NOTE_UP,
    Controls.list.NOTE_RIGHT
}

---
--- @param  strumLine  funkin.gameplay.StrumLine
--- @param  lane       integer
---
function boing(strumLine, lane)
    local json = NoteSkin.get(strumLine:getSkin())

    if not tweens[strumLine] then
        tweens[strumLine] = {nil, nil, nil, nil}
    end
    local receptor = strumLine.receptors:getMembers()[lane + 1] --- @type funkin.gameplay.Receptor
    receptor.scale:set(json.receptors.scale * 2, json.receptors.scale * 0.5)

    if tweens[strumLine][lane] then
        tweens[strumLine][lane]:free()
    end
    local t = Tween:new() --- @type chip.tweens.Tween
    t:tweenProperty(receptor, "scale", Point:new(json.receptors.scale, json.receptors.scale), 0.25):setEase(Ease.backOut)
    tweens[strumLine][lane] = t
end

---
--- @param  e  funkin.backend.events.NoteHitEvent
---
function onNoteHit(e)
    local strumLine = e:getStrumLine()
    boing(strumLine, e:getLane())
end

function onInputReceived(e)
    if e:isRepeating() then
        return
    end
    for i = 1, 4 do
        if controls[i]:check(InputState.JUST_PRESSED) then
            boing(game.playerStrumLine, i - 1)
        end
    end
end