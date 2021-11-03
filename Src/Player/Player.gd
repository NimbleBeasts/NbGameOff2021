extends KinematicBody2D

const MAX_RECORD_FRAMES = 120000 # at least -> movement = 60 fps * (5min*60s) + anim changes
const DEFAULT_GRAVITY = Vector2(0, 10)
const JUMP_FORCE = 250
const STOP_FORCE_FLOOR = 700
const STOP_FORCE_AIR = 80
const WALK_FORCE = 1600
const MAX_SPEED = 140

var counter = 0
var state = {
	"ghost_no": -1,
	"dead": false,
	
	# Movement
	"velocity": Vector2(0,0),
	"jumping": false,
	"has_jumped": false,
	"air_time": 0,
	"ladder_area": null,
	"is_on_ladder": false,
}

var data_record = []

func is_ghost():
	return false if state.ghost_no == -1 else true

func setup_and_start(ghost_no):
	print("setup: " + str(ghost_no))
	state.ghost_no = ghost_no
	
	if is_ghost():
		data_record = Ghosts.data[ghost_no].duplicate()
		print("data size: " + str(data_record.size()))
		self.collision_layer = 8
		$Sprite.modulate = Color("#aaffffff")
	else:
		self.collision_layer = 4

func _physics_process(delta):
	if is_ghost():
		# Ghost
		process_ghost(delta)
	
	elif not state.dead:
		# Player
		var input_direction = get_direction_input()
		
		update_animation()
		
		process_movement(delta, input_direction)
		
		# Record movement
		add_movement_record()
		
		# Handle restart request
		process_restart()



func update_animation():
	var anim = ""
	
	if abs(state.velocity.x) > 0.1:
		anim = "walk"
	else:
		anim = "idle"
	if state.velocity.y > 16:
		anim = "falling"
	elif state.velocity.y < 0:
		anim = "jump"
	
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)
		add_animation_record(anim)



func process_ghost(delta):
	# TODO: make this timestamp based
	
	var data_line = data_record.pop_front()
	$Label.set_text(str(data_line))
	
	if data_line:
		if data_line.get("pos"):
			position = data_line.pos
		else:
			$AnimationPlayer.play(data_line.anim)
			
	else:
		state.velocity.y += DEFAULT_GRAVITY.y
		state.velocity = move_and_slide(state.velocity, Vector2(0, -1))


func add_movement_record():
	if data_record.size() < MAX_RECORD_FRAMES:
		data_record.append({"t": Ghosts.get_time(), "pos": position})
		$Label.set_text("Data: " + str(data_record.size()))

func add_animation_record(anim):
	if data_record.size() < MAX_RECORD_FRAMES:
		data_record.append({"t": Ghosts.get_time(), "anim": anim})
		$Label.set_text("Data: " + str(data_record.size()))

func process_movement(delta, input_direction):
	if state.is_on_ladder:
		return
	
	var on_floor_or_ghost = is_on_floor_or_ghost()
	
	# Jumping
	if on_floor_or_ghost:
		# Reset Jump state
		state.jumping = false
		state.has_jumped = false
		state.air_time = 0
	else:
		state.air_time += 1 # TODO: use delta - anyway do we need air time? xD

	if Input.is_action_just_pressed('ui_jump') and on_floor_or_ghost and not state.jumping:
		state.velocity.y =- JUMP_FORCE
		state.jumping = true
		state.has_jumped = true
	
	# Stop movement
	if input_direction == Vector2(0.0, 0.0):
		var stop_force = delta
		if on_floor_or_ghost:
			stop_force *= STOP_FORCE_FLOOR
		else:
			stop_force *= STOP_FORCE_AIR
			
		if state.velocity.x > 0:
			state.velocity.x = max(state.velocity.x - stop_force, 0)
		elif state.velocity.x < 0:
			state.velocity.x = min(state.velocity.x + stop_force, 0)
	# Accelarete
	else:
		state.velocity.x += input_direction.x * delta * WALK_FORCE
		if state.velocity.x > MAX_SPEED:
			state.velocity.x = MAX_SPEED
		elif state.velocity.x < -MAX_SPEED:
			state.velocity.x = -MAX_SPEED
	
	state.velocity.y += DEFAULT_GRAVITY.y
	state.velocity = move_and_slide(state.velocity, Vector2(0, -1))


func die():
	state.dead = true
	$AnimationPlayer.play("die")

func set_ladder_area(val):
	if val != state.ladder_area:
		state.ladder_area = val
	else:
		state.ladder_area = null
	print(state.ladder_area)

func process_restart():
	if Input.is_action_just_pressed('ui_restart'):
		add_animation_record("idle") #reset to idle before stopping
		print("restart-----")
		Ghosts.add_ghost(data_record)
		Events.emit_signal("restart_level")
		

func is_on_floor_or_ghost():
	var collision = is_on_floor()
	
	if not collision:
		# TODO: Check for ghost collision here
		pass

	return collision

func get_direction_input():
	var input = Vector2(0, 0)
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"die":
			Events.emit_signal("restart_level")
		_:
			pass
