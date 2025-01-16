function onInitPost()
    game.playerCharacter:setTint(Color.RED)
end

function onUpdate(dt)
    local dad = game.playerCharacter
    dad:setRotationDegrees(dad:getRotationDegrees() + (dt * 180.0))
end