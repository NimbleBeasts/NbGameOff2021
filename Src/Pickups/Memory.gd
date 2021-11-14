extends Area2D

var pickup_scene = preload("res://Src/Pickups/Pickup.tscn")

var picked_up = false

func _ready():
	get_parent().get_parent().add_memory()

func _on_Memory_body_entered(body):
	if not picked_up:
		picked_up = true
		$AudioStreamPlayer2D.play()
		$Sprite.hide()
		var pickup = pickup_scene.instance()
		get_parent().add_child(pickup)
		pickup.global_position = global_position
		get_parent().get_parent().pickup_memory()


func _on_AudioStreamPlayer2D_finished():
	queue_free()
