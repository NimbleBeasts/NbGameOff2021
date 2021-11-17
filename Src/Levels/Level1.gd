extends "res://Src/Levels/LevelBase.gd"



# Events needed:
# Start: Suppress player restart mechanism
#		 suppress shooting mechanism
# Tut3_End: enable local restart mechanism
# 			enable diag caller 4

var quick_restart_enabled = false
var player = null


func _ready():
	
	connect("player_spawned", self, "_player_spawned")
	
	Events.connect("tutorial_step3_completed", self, "_tutorial_step3_completed")

	if GameData.tutorial_state_3 == true:
		_tutorial_step3_completed()

func _physics_process(delta):
	if quick_restart_enabled:
		if Input.is_action_just_pressed("ui_restart"):
			player.restart_callback(true)


func _player_spawned(node):
	# Suspend the respawn menu
	node.state.suspend_respawn = true
	player = node


func _tutorial_step3_completed():
	GameData.tutorial_state_3 = true
	quick_restart_enabled = true
	
	$Objects/DiagCaller1.monitoring = false
	$Objects/DiagCaller4.monitoring = true
	
