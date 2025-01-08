local modName = Paths.currentMod
local fs = love.filesystem

function init()
    registerSongs()
    registerLevels()
end

function getModDirectory()
    return "mods/" .. modName
end

function registerSongs()
    local songList = table.filter(fs.getDirectoryItems(getModDirectory() .. "/songs"), function(song)
        return fs.getInfo(getModDirectory() .. "/songs/" .. song, "directory")
    end)
    for i = 1, #songList do
        local songID = songList[i] --- @type string
        SongRegistry.instance:registerEntry(songID, Json.parse(File.read(getModDirectory() .. "/songs/" .. songID .. "/meta.json")))
    end
end

function registerLevels()
    local levelList = table.filter(fs.getDirectoryItems(getModDirectory() .. "/data/levels"), function(level)
        return fs.getInfo(getModDirectory() .. "/data/levels/" .. level, "file") and level:endsWith(".json")
    end)
    for i = 1, #levelList do
        local levelID = levelList[i] --- @type string
        LevelRegistry.instance:registerEntry(levelID:sub(1, #levelID - 5), Json.parse(File.read(getModDirectory() .. "/data/levels/" .. levelID)))
    end
end