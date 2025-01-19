function onInitPost()
    local cumShader = Shader:new(Paths.frag("cum"))
    game.playerCharacter:setShader(cumShader)
end