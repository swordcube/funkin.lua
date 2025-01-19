Chip = require("chip") --- @type chip.Chip
Chip.init({
    gameWidth = 1280,
    gameHeight = 720,
    targetFPS = 144,
    initialScene = require("funkin.scenes.InitScene"):new(),
    showSplashScreen = true,
    debugMode = false
})