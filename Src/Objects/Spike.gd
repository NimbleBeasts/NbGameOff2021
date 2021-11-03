extends Area2D


func _on_Spike_body_entered(body):
	if body.has_method("die"):
		body.die()
