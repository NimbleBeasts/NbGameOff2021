extends Control

var ghost_indicator_scene = preload("res://Src/Hud/HudGhostIndicator.tscn")
var ghost_indicator_refs = []

var callback = null

func _ready():
	Events.connect("ghost_added", self, "_ghost_added")
	Events.connect("ghost_clear", self, "_ghost_clear")
	Events.connect("ghost_spawn", self, "_ghost_spawn")
	Events.connect("ghost_dialogue_popup", self, "_ghost_dialogue_popup")
	
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

func _ghost_dialogue_popup(callback_ref):
	callback = callback_ref
	get_tree().paused = true
	$GhostBox/SaveGhostButton
	$GhostBox.move_child($GhostBox/SaveGhostButton, $GhostBox.get_child_count())
	$AnimationPlayer.play("popup")

func _on_WipeButton_button_up():
	Ghosts.clear_ghosts()
	callback.call_func(false)
	$AnimationPlayer.play_backwards("popup")

func _on_DiscardButton_button_up():
	callback.call_func(false)
	$AnimationPlayer.play_backwards("popup")

func _on_SaveGhostButton_button_up():
	callback.call_func(true)
	$AnimationPlayer.play_backwards("popup")

func _on_AnimationPlayer_animation_finished(anim_name):
	if $DiscardButton.visible: # Determine if it was played backwards
		$DiscardButton.grab_focus()
	else:
		get_tree().paused = false



