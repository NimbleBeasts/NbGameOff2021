extends Area2D

var pickup_scene = preload("res://Src/Pickups/Pickup.tscn")

var picked_up = false




func _on_AudioStreamPlayer2D_finished():
	queue_free()


func _on_Bullet_body_entered(body):
	if not picked_up:
		
		if not body.state.has_bullet:
			picked_up = true
			$AudioStreamPlayer2D.play()
			$Sprite.hide()
			var pickup = pickup_scene.instance()
			get_parent().add_child(pickup)
			pickup.global_position = global_position
			body.state.has_bullet = true
			Events.emit_signal("notification_popup", "PICKUP_AMMO")
			Events.emit_signal("ammo_update", 1)

