extends ParallaxBackground


func _ready():
	Events.connect("shader_matrix", self, "_shader_toggle")
	_shader_toggle(Global.userConfig.moving_bg)

func _shader_toggle(state):
	if state:
		$Layer1/Sprite.material.set_shader_param("scroll_speed", 0.3)
		$Layer2/Sprite.material.set_shader_param("scroll_speed", 0.4)
		$Layer3/Sprite.material.set_shader_param("scroll_speed", 0.5)
	else:
		$Layer1/Sprite.material.set_shader_param("scroll_speed", 0.0)
		$Layer2/Sprite.material.set_shader_param("scroll_speed", 0.0)
		$Layer3/Sprite.material.set_shader_param("scroll_speed", 0.0)
