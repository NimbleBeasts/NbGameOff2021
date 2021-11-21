extends TextureButton


var textures_screenshots = [
	load("res://Assets/Menu/LevelScreenshots/Screenshots.png"),
	load("res://Assets/Menu/LevelScreenshots/Screenshots.png"),
	load("res://Assets/Menu/LevelScreenshots/Screenshots.png"),
	load("res://Assets/Menu/LevelScreenshots/Screenshots.png"),
	load("res://Assets/Menu/LevelScreenshots/Screenshots.png")
]

var texture_locked = preload("res://Assets/Menu/LevelScreenshots/Locked.png")
var texture_void = preload("res://Assets/Menu/LevelScreenshots/Void.png")

func set_level(id, state):
	
	$Title.set_text("Level " + str(id + 1))
	
	match state:
		Types.MenuLevelSelectionType.Normal:
			$Title.show()
			$BgTexture.texture = textures_screenshots[id]
			disabled = false
		Types.MenuLevelSelectionType.Locked:
			$Title.show()
			$BgTexture.texture = texture_locked
			disabled = true
		Types.MenuLevelSelectionType.Void:
			$Title.hide()
			$BgTexture.texture = texture_void
			disabled = true
		_:
			printerr("invalid set_level state")
