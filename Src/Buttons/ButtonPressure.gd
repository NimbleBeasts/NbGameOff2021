extends Area2D


export(Array, NodePath) var trigger_nodes = null 

var bodies_on_button = []

var triggered = false

func _ready():
	$Light2D.color = Color("#b13e53")

func add_body(body):
	if bodies_on_button.find(body) == -1:
		bodies_on_button.append(body)
	
	if not triggered:
		triggered = true
		$AnimationPlayer.play("trigger")
		trigger()


func remove_body(body):
	var id = bodies_on_button.find(body)
	
	if id != -1:
		bodies_on_button.remove(id)

	#print(bodies_on_button)
	if bodies_on_button.size() == 0:
		triggered = false
		$AnimationPlayer.play_backwards("trigger")
		trigger()

func trigger():
	if trigger_nodes:
		for node_path in trigger_nodes:
			var node = get_node(node_path)
			if node != null:
				node.trigger()

func _on_ButtonPressure_body_entered(body):
	add_body(body)


func _on_ButtonPressure_body_exited(body):
	remove_body(body)
