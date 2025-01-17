function onInputReceived(_)
    if Input.wasKeyJustPressed(KeyCode.F2) then
        local time = Conductor.instance:getRawTime() - Conductor.instance:getCrotchet()
        Conductor.instance:setTime(time)

        BGM.audioPlayer:seek(time / 1000.0)
        for _, value in pairs(game.vocalTracks) do
            value:seek(time / 1000.0)
        end
    end
    if Input.wasKeyJustPressed(KeyCode.F3) then
        local time = Conductor.instance:getRawTime() + Conductor.instance:getCrotchet()
        Conductor.instance:setTime(time)

        BGM.audioPlayer:seek(time / 1000.0)
        for _, value in pairs(game.vocalTracks) do
            value:seek(time / 1000.0)
        end
    end
end