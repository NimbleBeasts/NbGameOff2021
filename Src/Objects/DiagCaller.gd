extends Area2D
class_name DiagCaller


export(float) var delay_timer = 0.0
export(Array, String) var texts = []

var message_counter = 0

func spawn_message():
	if message_counter < texts.size():
		Events.emit_signal(
			"dialogue_popup",
			Types.CharacterType.Tutorial, # Talking
			texts[message_counter], # Text
			(message_counter == texts.size() - 1), # Last Text?
			funcref(self, "callback") # Callback
		)


func callback():
	message_counter += 1
	spawn_message()


func _ready():
	assert(texts.size() > 0)
	
	if delay_timer > 0.0:
		$DelayTimer.wait_time = delay_timer


func _on_DiagCaller_body_entered(body):
	if Ghosts.dialogue_nodes.find(texts[0]) != -1:
		pass
	else:
		Ghosts.dialogue_nodes.append(texts[0])
	
		if delay_timer > 0.0:
			$DelayTimer.start()
		else:
			spawn_message()
		
	print(Ghosts.dialogue_nodes)


func _on_DelayTimer_timeout():
	spawn_message()
