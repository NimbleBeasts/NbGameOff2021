extends Node2D

const GHOST_SPAWN_DELAY = 2.0

signal player_spawned(node)

export(Types.MusicTracks) var music_track = Types.MusicTracks.Normal

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
	GameData.start_time()
	
	Events.emit_signal("change_music", music_track)
	
	# Set last spawn
	set_active_spawner(GameData.spawner_id, false)
	
	# Set camera until player appears
	spawn_camera()
	
	# Spawn ghosts & Player
	for i in range(0, GameData.get_number_of_ghosts()):
		spawn_player(i)
	
	spawn_player()


func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Events.emit_signal("menu_back")

	if GameData.memory_total > 0:
		if GameData.memory_pickup.size() == GameData.memory_total:
			$Spawns/Portal.open()

func set_active_spawner(id, clear_ghosts = true):
	GameData.spawner_id = id
	
	# Search for spawn node
	for spawn in $Spawns.get_children():
		if spawn.spawner_id == id:
			spawn_node = spawn
			spawn_node.set_active(id) # When called from _ready the node doesnt know its active
			break
	
	if clear_ghosts:
		# Remove all ghosts
		GameData.clear_ghosts()

func spawn_bullet(emitter, direction, pos, type):
	var bullet = bullet_scene.instance()
	$Objects.add_child(bullet)
	bullet.shoot(emitter, direction, pos, type)

func spawn_camera():
	camera = camera_scene.instance()
	camera.position = spawn_node.position + Vector2(0, 4)
	add_child(camera)

func spawn_player(ghost_no = -1):
	var delay = GHOST_SPAWN_DELAY * GameData.get_number_of_ghosts() if ghost_no == -1 else GHOST_SPAWN_DELAY * ghost_no
	
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
		emit_signal("player_spawned", new_player)

	# Update HUD
	Events.emit_signal("ghost_spawn", ghost_no)
	


func _on_ButtonClear_button_up():
	GameData.clear_ghosts()
