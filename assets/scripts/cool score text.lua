function getRank(accuracy)
    if accuracy == 0 then
        return "N/A"
    end
    if accuracy >= 100 then
        return "S+"
    elseif accuracy >= 90 then
        return "S"
    elseif accuracy >= 80 then
        return "A"
    elseif accuracy >= 70 then
        return "B"
    elseif accuracy >= 60 then
        return "C"
    elseif accuracy >= 50 then
        return "D"
    end
    return "F"
end

function onInitPost()
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    game.scoreText:setY(game.scoreText:getY() + 4)
end

---
--- @param  e  funkin.backend.events.CancellableEvent
---
function onUpdateScoreText(e)
    e:cancel()
    
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    game.scoreText:setContents(
        "Score: " .. math.formatMoney(game.player.stats:getScore(), false, true) ..
        " • Combo Breaks: " .. math.formatMoney(game.player.stats.comboBreaks, false, true) ..
        " • Accuracy: " .. math.truncate(game.player.stats:getAccuracy() * 100, 2) .. "%" .. 
        " • Rank: " .. getRank(game.player.stats:getAccuracy() * 100)
    )
    game.scoreText:screenCenter("x")
end