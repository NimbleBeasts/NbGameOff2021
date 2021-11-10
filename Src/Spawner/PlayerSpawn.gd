extends Position2D

export(int) var spawner_id = 0

var player = null
var is_active = false

func _ready():
	Events.connect("ghost_set_spawner", self, "set_active")


func set_active(id):
	if spawner_id == id:
		$Spawner.frame = 1
		is_active = true
	else:
		$Spawner.frame = 0
		is_active = false

func play_anim(player_node):
	player = player_node
	$TeleportSound.play()
	$AnimationPlayer.play("beam")

func show_player(): #Called by animation
	player.show()

func _on_Area2D_body_entered(body):
	if not is_active:
		print("spawner_set")
		is_active = true
		Events.emit_signal("ghost_set_spawner", spawner_id)
		body.spawn_activated(global_position)
		$CheckPointSound.play()
