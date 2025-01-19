local HealthIcon = require("funkin.ui.HealthIcon") --- @type funkin.ui.HealthIcon

function onUpdatePost(dt)
    local game = Gameplay.instance --- @type funkin.scenes.Gameplay
    game.iconP2:setY(game.healthBar:getY() - (HealthIcon.HEALTH_ICON_SIZE * 0.5) + ((game.iconP2:getHeight() - HealthIcon.HEALTH_ICON_SIZE) * 0.5))
    game.iconP1:setY(game.healthBar:getY() - (HealthIcon.HEALTH_ICON_SIZE * 0.5) + ((game.iconP1:getHeight() - HealthIcon.HEALTH_ICON_SIZE) * 0.5))
end

function onBeatHit(b)
    HealthIcon.ICON_SPEED = math.preciseRandom(0.01, 0.05)
end