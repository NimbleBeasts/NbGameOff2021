extends Area2D
class_name DiagCaller


export(float) var delay_timer = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	if delay_timer > 0.0:
		$DelayTimer.wait_time = delay_timer




func _on_DiagCaller_body_entered(body):
	pass # Replace with function body.


func _on_DelayTimer_timeout():
	pass # Replace with function body.
