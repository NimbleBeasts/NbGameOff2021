extends Area2D
class_name DiagCaller


export(float) var delay_timer = 0.0
export(String) var text_id = ""


#const message_data = [
#	{"id": "tut1", "data": [
#		{"char": Types.CharacterType.Tutorial, "text": "TEXT_1", "events": []},
#		{"char": Types.CharacterType.Player, "text": "TEXT_2", "events": ["test_event"]},
#	]}
#]
var text_buffer = null
var message_counter = 0

func TEST_EVENT():
	print("test event")

func _ready():
	# Grab related data
	for data_blob in GameData.message_data:
		if data_blob.id == text_id:
			text_buffer = data_blob.data
			break
	assert(text_buffer)

	if delay_timer > 0.0:
		$DelayTimer.wait_time = delay_timer
	
	Events.connect("test_event", self, "TEST_EVENT")


func spawn_message():
	if message_counter < text_buffer.size():
		Events.emit_signal(
			"dialogue_popup",
			text_buffer[message_counter].char, # Char talking
			tr(text_buffer[message_counter].text), # Text
			(message_counter == text_buffer.size() - 1), # Last Text?
			funcref(self, "_callback") # Callback
		)


func _callback():
	for event in text_buffer[message_counter].events:
		Events.emit_signal(event)
	
	message_counter += 1
	spawn_message()


func _on_DiagCaller_body_entered(body):
	if not Global.tutorials_disabled:
		if GameData.dialogue_nodes.find(text_id) != -1:
			pass
		else:
			GameData.dialogue_nodes.append(text_id)
		
			if delay_timer > 0.0:
				$DelayTimer.start()
			else:
				spawn_message()


func _on_DelayTimer_timeout():
	spawn_message()
