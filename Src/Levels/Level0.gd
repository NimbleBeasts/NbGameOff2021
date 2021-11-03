extends Node2D

const GHOST_SPAWN_DELAY = 1.0

var player_scene = preload("res://Src/Player/Player.tscn")

var ghosts = []

func _on_ButtonBack_button_up():
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("menu_back")



func _ready():
	spawn_player()


func spawn_player(ghost_no = -1):
	# Level must contain a spawn
	assert($PlayerSpawn)
	
	var spawn_position = $PlayerSpawn.position
	
	# Instance player
	var new_player = player_scene.instance()
	new_player.position = spawn_position
	
	# Delay spawning
	yield(get_tree().create_timer(GHOST_SPAWN_DELAY * ghosts.size()), "timeout")
	$Objects.add_child(new_player)
	new_player.setup_and_start(ghost_no)
	
