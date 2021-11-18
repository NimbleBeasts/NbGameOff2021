extends Area2D


var pickup_scene = preload("res://Src/Pickups/Pickup.tscn")

export(int) var id = 0

var picked_up = false

func _ready():
	# Memory total is resetted every time the level reloads
	GameData.memory_total += 1
	Events.emit_signal("memory_update_total", GameData.memory_total)
	
	# Check if already looted
	if GameData.memory_pickup.find(id) != -1:
		queue_free()
	
	

func _on_Memory_body_entered(body):
	if not picked_up:
		picked_up = true
		$AudioStreamPlayer2D.play()
		$Sprite.hide()

		var pickup = pickup_scene.instance()
		get_parent().add_child(pickup)
		pickup.global_position = global_position

		body.state.pickup.append(id)
		GameData.memory_pickup.append(id)
		Events.emit_signal("memory_update_collected", GameData.memory_pickup.size())


func _on_AudioStreamPlayer2D_finished():
	queue_free()
