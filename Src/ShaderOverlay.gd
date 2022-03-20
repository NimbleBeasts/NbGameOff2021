extends ColorRect


#
func _ready():
	Events.connect("shader_glitch", self, "_shader_toggle")
	_shader_toggle(Global.userConfig.glitch)

func _shader_toggle(state):
	if state:
		self.show()
	else:
		self.hide()
