extends Control

var ghost_indicator_scene = preload("res://Src/Hud/HudGhostIndicator.tscn")
var ghost_indicator_refs = []

var callback = null

var memory_total = 0
var memory_collected = 0

var _ghost_dialogue_visible = false
var _menu_popup_visible = false

func _ready():
	Events.connect("ghost_added", self, "_ghost_added")
	Events.connect("ghost_clear", self, "_ghost_clear")
	Events.connect("ghost_spawn", self, "_ghost_spawn")
	Events.connect("ghost_dialogue_popup", self, "_ghost_dialogue_popup")
	
	Events.connect("memory_update_total", self, "_memory_update_total")
	Events.connect("memory_update_collected", self, "_memory_update_collected")
	Events.connect("notification_popup", self, "_notification_popup")
	
	Events.connect("menu_popup", self, "_menu_popup")
	
	Events.connect("ammo_update", self, "_ammo_update")
	$AmmoLabel.set_text("0/0")

func _process(delta):
	if _ghost_dialogue_visible:
		if Input.is_action_just_pressed("ui_cancel"):
			_ghost_dialogue_visible = false
			$AnimationPlayer.play_backwards("popup")
			yield(get_tree().create_timer(0.5), "timeout")
			get_tree().paused = false
	if _menu_popup_visible:
		if Input.is_action_just_pressed("ui_cancel"):
			print("esc hud")
			_on_ContinueButton_button_up()

func _ghost_dialogue_popup(callback_ref):
	callback = callback_ref
	_ghost_dialogue_visible = true
	get_tree().paused = true
	$GhostBox.move_child($GhostBox/SaveGhostButton, $GhostBox.get_child_count())
	$AnimationPlayer.play("popup")

func _ammo_update(amnt):
	$AmmoLabel.set_text(str(amnt)+"/1")

func _notification_popup(text):
	$NotificationLabel.set_text(tr(text))
	$NotificationLabel/AnimationPlayer.play("popup")

func _memory_update_total(total):
	memory_total = total
	update_memory_label()

func _memory_update_collected(update):
	memory_collected = update
	update_memory_label()

func update_memory_label():
	$MemoryLabel.set_text(str(memory_collected) + "/" + str(memory_total))


func _ghost_added():
	var new_ghost = ghost_indicator_scene.instance()
	$GhostBox.add_child(new_ghost)
	ghost_indicator_refs.append(new_ghost)
	$GhostBox.move_child($GhostBox/HudPlayerIndicator, $GhostBox.get_child_count())
	
func _ghost_clear():
	for ghost in ghost_indicator_refs:
		ghost.queue_free()
	ghost_indicator_refs = []

func _ghost_spawn(id):
	if id == -1:
		$GhostBox/HudPlayerIndicator.play_spawn_anim()
	elif id < ghost_indicator_refs.size():
		ghost_indicator_refs[id].play_spawn_anim()


func _on_WipeButton_button_up():
	GameData.clear_ghosts()
	callback.call_func(false)
	$AnimationPlayer.play_backwards("popup")
	Events.emit_signal("play_sound", "menu_click")

func _on_DiscardButton_button_up():
	callback.call_func(false)
	$AnimationPlayer.play_backwards("popup")
	Events.emit_signal("play_sound", "menu_click")

func _on_SaveGhostButton_button_up():
	callback.call_func(true)
	$AnimationPlayer.play_backwards("popup")
	Events.emit_signal("play_sound", "menu_click")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "popup":
		if $DiscardButton.visible: # Determine if it was played backwards
			$DiscardButton.grab_focus()
		else:
			get_tree().paused = false
	else:
		if $Menu.visible: # Backwards?
			$Menu/ContinueButton.grab_focus()
		else:
			_menu_popup_visible = false

func _menu_popup():
	get_tree().paused = true
	_menu_popup_visible = true
	$AnimationPlayer.play("menu")
	

func _on_ContinueButton_button_up():
	$AnimationPlayer.play_backwards("menu")
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().paused = false
	_menu_popup_visible = false

func _on_ExitButton_button_up():
	$AnimationPlayer.play_backwards("menu")
	_menu_popup_visible = false
	get_tree().paused = false
	_ghost_clear()
	Events.emit_signal("menu_back")
