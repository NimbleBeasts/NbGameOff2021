extends Node2D


export(bool) var opened_at_start = false
var opened = false

func _ready():
	opened = opened_at_start

	if opened:
		$Sprite.frame = 3
		$AnimationPlayer.play("open", -1, 100.0) # Play to resize the collision shape


func trigger():
	if opened:
		$AnimationPlayer.play_backwards("open")
		$CloseSound.play()
	else:
		$AnimationPlayer.play("open")
		$OpenSound.play()

	opened = !opened
