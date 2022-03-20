extends Node2D

export(Array, NodePath) var trigger_nodes = null

var triggered = false

func die(): # Button was shot
	_on_ButtonVertical_body_entered(null)


func _on_AnimationPlayer_animation_finished(_anim_name):
	if trigger_nodes:
		for node_path in trigger_nodes:
			var node = get_node(node_path)
			if node != null:
				node.trigger()


func _on_ButtonVertical_body_entered(body):
	if not triggered:
		triggered = true
		$AnimationPlayer.play("trigger")
