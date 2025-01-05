local fs = love.filesystem

function init()
    -- this code below is concept code
    -- SongRegistry.registerSongs(fs.getDirectoryItems("assets/songs"):filter(function(song)
    --     return fs.getInfo("assets/songs/" .. song, "directory")
    -- end))
    -- LevelRegistry.registerLevels(fs.getDirectoryItems("assets/levels"):filter(function(song)
    --     return fs.getInfo("assets/levels/" .. song, "directory")
    -- end))
end

function onInputReceived(e)
    if e:is(InputEventKey) then
        local keyEvent = e --- @type chip.input.InputEventKey
        if keyEvent:getKey() == KeyCode.F5 and keyEvent:isPressed() then
            -- Have to wait a frame before reloading everything
            -- otherwise stupid recursive bullshittery happens
            -- and it endlessly reloads over and over every frame
            -- basically making the game unplayable
            Timer:new():start(0.001, function()
                ModLoader.updateModList()
                print("Reloaded mod list")
    
                ModLoader.reloadMainScripts()
                print("Reloaded all main scripts")
    
                Engine.switchScene(require(Engine.currentScene.__path):new())
                print("Reloaded current scene")
            end)
        end
    end
    
end