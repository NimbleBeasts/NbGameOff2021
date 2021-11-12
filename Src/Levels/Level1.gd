extends "res://Src/Levels/LevelBase.gd"



# Events needed:
# Start: Suppress player restart mechanism
#		 suppress shooting mechanism
# Tut3_End: enable local restart mechanism
# 			enable diag caller 4

var quick_restart_enabled = false

func _ready():
	Events.connect("tutorial_step3_completed", self, "_tutorial_step3_completed")

	if GameData.tutorial_state_3 == true:
		_tutorial_step3_completed()


func _tutorial_step3_completed():
	GameData.tutorial_state_3 = true
	quick_restart_enabled = true
	
	$Objects/DiagCaller1.monitoring = false
	$Objects/DiagCaller4.monitoring = true
	
