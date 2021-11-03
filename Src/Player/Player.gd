extends KinematicBody2D

const DEFAULT_GRAVITY = Vector2(0, 10)
const JUMP_FORCE = 250
const STOP_FORCE_FLOOR = 700
const STOP_FORCE_AIR = 80
const WALK_FORCE = 1600
const MAX_SPEED = 140

var state = {
	"ghost_no": -1,
	
	# Movement
	"velocity": Vector2(0,0),
	"jumping": false,
	"has_jumped": false,
	"air_time": 0,
}

var data_record = []

func is_ghost():
	return false if state.ghost_no == -1 else true

func setup_and_start(ghost_no):
	print("setup: " + str(ghost_no))
	state.ghost_no = ghost_no
	
	if ghost_no != -1:
		data_record = Ghosts.data[ghost_no].duplicate()
		print("data size: " + str(data_record.size()))

func _physics_process(delta):
	if is_ghost():
		# Ghost
		process_ghost(delta)
	else:
		# Player
		process_movement(delta)
		
		# Record movement
		add_data_record()
		
		# Restart
		process_restart()

func process_ghost(delta):
	# TODO: make this timestamp based
	
	var movement = data_record.pop_front()
	$Label.set_text(str(movement))
	
	if movement:
		position = movement.pos
	

func add_data_record():
	data_record.append({"t": Ghosts.get_time(), "pos": position})
	$Label.set_text("Data: " + str(data_record.size()))

func process_movement(delta):
	var input_direction = get_direction_input()
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

func process_restart():
	if Input.is_action_just_pressed('ui_restart'):
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
