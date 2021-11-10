extends Control

var text_buffer = ""
var text_buffer_length = 0
var last_dialogue = false
var popup_state = false
var timer_stopped = true
var callback = null
var text_anim_done = false
var active = false

var portraits = [preload("res://Assets/Hud/PortraitTutor.png"), preload("res://Assets/Hud/PortraitPlayer.png")]
var names = ["Tutor","Player"]

func _ready():
	Events.connect("dialogue_popup", self, "_popup")

	#_popup(Types.CharacterType.Tutorial, "Text test alala asd asd asd as asd", false, funcref(self, "testcbk"))

#func testcbk():
#	print("testcbk")
#	_popup(Types.CharacterType.Tutorial, "Text2 test alala asd asd asd as asd", true, funcref(self, "testcbk2"))
#
#func testcbk2():
#	print("end")

func _physics_process(delta):
	if active:
		if Input.is_action_just_pressed('ui_shoot') or Input.is_action_just_pressed('ui_jump'):
			if not text_anim_done:
				_stop_text_anim()
			else:
				if last_dialogue:
					$AnimationPlayer.play_backwards("pop_in")
					get_tree().paused = false

				active = false
				callback.call_func()


func _popup(character, text, last_diag, callback_function):
	active = true
	var char_name = ""
	# Set Portrait
	char_name = names[character]
	$Box/PortraitTexture.texture = portraits[character]
	
	text_buffer = text
	last_dialogue = last_diag
	callback = callback_function
	text_anim_done = false
	
	$Box/Text.bbcode_text = "[color=#8a8fc4]"+ char_name + ":[/color] " + text_buffer
	$Box/Text.visible_characters = char_name.length() + 2
	
	text_buffer_length = text_buffer.length() + char_name.length() + 2
	
	$Box/NextTexture.hide()
	$Box/DoneTexture.hide()
	
	if not popup_state:
		$AnimationPlayer.play("pop_in")
	else:
		_on_AnimationPlayer_animation_finished("")
	
	get_tree().paused = true
	
func _set_popup_state(state):
	popup_state = state

func _start_text_anim():
	if $Box/Text.visible_characters < text_buffer_length:
		$Box/Text.visible_characters += 1
		$TypeSound.play()
	else:
		_stop_text_anim()

func _stop_text_anim():
	$Box/Text.visible_characters = text_buffer_length
	$CharacterTimer.stop()
	timer_stopped = true
	text_anim_done = true
	if last_dialogue:
		$Box/DoneTexture.show()
	else:
		$Box/NextTexture.show()


func _on_AnimationPlayer_animation_finished(anim_name):
	if not text_anim_done:
		timer_stopped = false
		$CharacterTimer.start()


func _on_CharacterTimer_timeout():
	_start_text_anim()
	if not timer_stopped:
		$CharacterTimer.start()
