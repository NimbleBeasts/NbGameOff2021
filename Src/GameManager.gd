extends Control

var state = Types.GameStates.Menu
var levelNode = null


func _ready():
	# Set Viewport Sizes to Project Settings
	$gameViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	$menuViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

	Global.debugLabel = $Debug

	# Event Hooks
	Events.connect("cfg_music_set_volume", self, "setMusicVolume")
	Events.connect("cfg_sound_set_volume", self, "setSoundVolume")
	Events.connect("cfg_change_brightness", self, "setBrightness")
	Events.connect("cfg_change_contrast", self, "setContrast")

	Events.connect("cfg_switch_fullscreen", self, "_switchFullscreen")
	Events.connect("new_game", self, "_newGame")
	Events.connect("restart_level", self, "_restartLevel")
	Events.connect("load_level", self, "_loadLevel")
	Events.connect("menu_back", self, "_backToMenu")

	Events.connect("shader_glow", self, "_shader_toggle")
	_shader_toggle(Global.userConfig.glow)

	switchTo(Types.GameStates.Menu)

	#print(Global.userConfig.glitch)

# State Transition Function
func switchTo(to):
	if to == Types.GameStates.Menu:
		$gameViewport.hide()
		$menuViewport.show()
		$menuViewport/Viewport/Menu.show()
	elif to == Types.GameStates.Game:
		$gameViewport.show()
		$menuViewport.hide()
		$menuViewport/Viewport/Menu.hide()
	state = to

# Load a level to the LevelHolder node
func loadLevel(number = 0):
	Global.current_level = number
	levelNode = load(Global.levels[number]).instance()
	$gameViewport.get_node("Viewport/LevelHolder").add_child(levelNode)

# Unloads a loaded level
func unloadLevel():
	$gameViewport.get_node("Viewport/LevelHolder").remove_child(levelNode)
	if levelNode:
		levelNode.queue_free()
	levelNode = null

func reloadLevel():
	unloadLevel()
	loadLevel(Global.current_level)
	get_tree().paused = false

###############################################################################
# Callbacks
###############################################################################

func _shader_toggle(state):
	var world = $gameViewport/Viewport/WorldEnvironment.environment
	if state:
		world.glow_enabled = true
	else:
		world.glow_enabled = false

	$gameViewport/Viewport/WorldEnvironment.environment = world
	#$menuViewport/Viewport/WorldEnvironment.environment = world

# Event Hook: Back from Game to Menu
func _backToMenu():
	unloadLevel()
	switchTo(Types.GameStates.Menu)

# Event Hook: New Game
func _newGame():
	GameData.new_level()
	_restartLevel()

func _loadLevel(id):
	GameData.new_level()
	if levelNode:
		unloadLevel()
	loadLevel(id)
	switchTo(Types.GameStates.Game)

func _restartLevel():
	if levelNode:
		unloadLevel()
	loadLevel(Global.current_level)
	switchTo(Types.GameStates.Game)

# Event Hook: Update user config for sound
func setSoundVolume(value):
	Global.userConfig.soundVolume = value
	Global.saveConfig()

# Event Hook: Update user config for music
func setMusicVolume(value):
	Global.userConfig.musicVolume = value
	Global.saveConfig()

func setBrightness(value):
	$gameViewport/Viewport/WorldEnvironment.environment.adjustment_brightness = value
	Global.userConfig.brightness = value
	Global.saveConfig()

func setContrast(value):
	$gameViewport/Viewport/WorldEnvironment.environment.adjustment_contrast = value
	Global.userConfig.contrast = value
	Global.saveConfig()
# Event Hook: Switch to fullscreen mode and update user config
func _switchFullscreen(value):
	Global.setFullscreen(value)
