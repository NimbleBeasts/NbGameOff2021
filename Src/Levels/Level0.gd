extends Node2D

const GHOST_SPAWN_DELAY = 1.0

var camera_scene = preload("res://Src/Camera/Camera.tscn")
var player_scene = preload("res://Src/Player/Player.tscn")

var camera

func _on_ButtonBack_button_up():
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("menu_back")



func _ready():
	# Level must contain a spawn
	assert($PlayerSpawn)
	
	Ghosts.start_time()
	
	# Set camera until player appears
	spawn_camera()
	
	# Spawn ghosts
	for i in range(0, Ghosts.get_number_of_ghosts()):
		spawn_player(i)
	
	spawn_player()

func spawn_camera():
	camera = camera_scene.instance()
	camera.position = $PlayerSpawn.position
	add_child(camera)

func spawn_player(ghost_no = -1):
	var spawn_position = $PlayerSpawn.position
	var delay = GHOST_SPAWN_DELAY * Ghosts.get_number_of_ghosts() if ghost_no == -1 else GHOST_SPAWN_DELAY * ghost_no
	
	# Instance player
	var new_player = player_scene.instance()
	new_player.position = spawn_position
	
	# Delay spawning
	yield(get_tree().create_timer(delay), "timeout")
	$Objects.add_child(new_player)
	new_player.setup_and_start(ghost_no)
	
	#Attach camera to player
	if ghost_no == -1:
		remove_child(camera)
		new_player.add_child(camera)
		camera.position = Vector2(0,0)
	


func _on_ButtonClear_button_up():
	Ghosts.clear_ghosts()
