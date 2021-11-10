extends Area2D


func _ready():
	$IdleSound.play()

func _on_Portal_body_entered(body):
	body.hide()
	body.state.dead = true
	$AnimationPlayer.play("close")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "close":
		if Global.current_level < Global.levels.size() - 1:
			# Next Level
			Events.emit_signal("load_level", Global.current_level + 1)
			
			if Global.userConfig.unlocked_level < Global.current_level:
				Global.userConfig.unlocked_level = Global.current_level
				Global.saveConfig()
			
		else:
			# Last Level
			print("add dialogues here")
