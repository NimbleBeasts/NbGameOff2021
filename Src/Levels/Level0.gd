extends Node2D

const GHOST_SPAWN_DELAY = 2.0

var camera_scene = preload("res://Src/Camera/Camera.tscn")
var player_scene = preload("res://Src/Player/Player.tscn")
var bullet_scene = preload("res://Src/Bullet/Bullet.tscn")

var camera = null

var spawn_node = null

func _on_ButtonBack_button_up():
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("menu_back")



func _ready():
	# Level must contain a spawn
	assert($Spawns/PlayerSpawn)
	spawn_node = $Spawns/PlayerSpawn
	
	Events.connect("shoot_bullet", self, "spawn_bullet")
	Events.connect("ghost_set_spawner", self, "set_active_spawner")
	Ghosts.start_time()
	
	# Set last spawn
	set_active_spawner(Ghosts.spawner_id, false)
	
	# Set camera until player appears
	spawn_camera()
	
	# Spawn ghosts & Player
	for i in range(0, Ghosts.get_number_of_ghosts()):
		spawn_player(i)
	
	spawn_player()
	


func set_active_spawner(id, clear_ghosts = true):
	Ghosts.spawner_id = id
	
	# Search for spawn node
	for spawn in $Spawns.get_children():
		if spawn.spawner_id == id:
			spawn_node = spawn
			spawn_node.set_active(id) # When called from _ready the node doesnt know its active
			break
	
	if clear_ghosts:
		# Remove all ghosts
		Ghosts.clear_ghosts()

func spawn_bullet(emitter, direction, pos):
	var bullet = bullet_scene.instance()
	$Objects.add_child(bullet)
	bullet.shoot(emitter, direction, pos)

func spawn_camera():
	camera = camera_scene.instance()
	camera.position = spawn_node.position + Vector2(0, 4)
	add_child(camera)

func spawn_player(ghost_no = -1):
	var delay = GHOST_SPAWN_DELAY * Ghosts.get_number_of_ghosts() if ghost_no == -1 else GHOST_SPAWN_DELAY * ghost_no
	
	# Instance player
	var new_player = player_scene.instance()
	new_player.position = spawn_node.position
	
	# Delay spawning
	yield(get_tree().create_timer(delay), "timeout")
	$Objects.add_child(new_player)
	new_player.setup_and_start(ghost_no)
	new_player.hide()
	spawn_node.play_anim(new_player)
	
	# Attach camera to player
	if ghost_no == -1:
		remove_child(camera)
		new_player.add_child(camera)
		camera.position = Vector2(0,0)

	# Update HUD
	Events.emit_signal("ghost_spawn", ghost_no)
	


func _on_ButtonClear_button_up():
	Ghosts.clear_ghosts()
