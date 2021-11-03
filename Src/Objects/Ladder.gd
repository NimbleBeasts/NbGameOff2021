extends Area2D


func _on_Ladder_body_entered(body):
	if body.has_method("set_ladder_area"):
		body.set_ladder_area(self)


func _on_Ladder_body_exited(body):
	if body.has_method("set_ladder_area"):
		body.set_ladder_area(self)
