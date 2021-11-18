extends KinematicBody2D


const MAX_RECORD_FRAMES = 120000 # at least -> movement = 60 fps * (5min*60s) + anim changes

const DEFAULT_GRAVITY = Vector2(0, 9)
const JUMP_FORCE = 200
const BOUNCE_FORCE = 150
const JUMP_FORCE_EXTERNAL = 280
const STOP_FORCE_FLOOR = 550
const STOP_FORCE_AIR = 20
const STOP_FORCE_LADDER = 800
const WALK_FORCE = 1200
const LADDER_FORCE = 1200
const MAX_SPEED = 96
const LADDER_CORRECTION_SPEED = 120

enum PlayerState {Normal, Ladder}
enum RecordEvent {Move, Anim, Shoot}

var counter = 0
var state = {
	"ghost_no": -1,
	"dead": false,
	"last_record_id": 0,
	"current_state": PlayerState.Normal,
	"suspend_respawn": false,
	"pickup": [],
	
	# Movement
	"velocity": Vector2(0,0),
	"jumping": false,
	"has_jumped": false,
	"air_time": 0,
	"ladder_area": null,
	"has_bullet": true,
	"extern_jump": false,
	"bounce": false,
}

var data_record = []

func _ready():
	$SpriteHolder/Sprite.set_material($SpriteHolder/Sprite.get_material().duplicate())
	Events.connect("ghost_clear", self, "ghost_clear")

func spawn_activated(pos):
	data_record = []
	global_position.x = pos.x
	state.velocity = Vector2(0, 0)
	add_movement_record()

func ghost_clear():
	if is_ghost():
		queue_free()

func is_ghost():
	return false if state.ghost_no == -1 else true

func setup_and_start(ghost_no):
	print("spawn_player: " + str(ghost_no))
	state.ghost_no = ghost_no
	
	if is_ghost():
		data_record = GameData.data[ghost_no].duplicate()
		print("data size: " + str(data_record.size()))
		self.collision_layer = 8
		#$SpriteHolder/Sprite.modulate = Color("#feffffff")
		$SpriteHolder/Sprite.material.set_shader_param("ghost_enabled", true)
	else:
		self.collision_layer = 4
		Events.emit_signal("ammo_update", 1)



func _physics_process(delta):
	if global_position.y > 666 and not state.dead:
		die()
		return
	
	if is_ghost():
		# Ghost-Mode
		process_ghost(delta)
	elif not state.dead:
		# Player-Mode
		var input_direction = get_direction_input()
		
		
		# Update Animation
		update_animation()
		
		# State Checks
		#check_enter_ladder_state(input_direction) # TODO: I hate ladders - maybe Ill never implement this :D
		
		# Process State
		match state.current_state:
			PlayerState.Normal:
				process_movement(delta, input_direction)
			PlayerState.Ladder:
				process_ladder(delta, input_direction)
			_:
				pass
		
		
		# Record movement
		add_movement_record()
		
		# Handle restart request
		process_restart()
		
#		if state.current_state == PlayerState.Ladder:
#			$Label2.set_text("Ladder")
#		else:
#			$Label2.set_text("Normal")

func check_enter_ladder_state(input):
	if state.ladder_area and state.current_state != PlayerState.Ladder:
		if input.y != 0:
			state.current_state = PlayerState.Ladder

func update_animation():
	var anim = ""
	
	if state.current_state == PlayerState.Ladder:
		pass
	else:
		if abs(state.velocity.x) > 0.1:
			anim = "walk"
		else:
			anim = "idle"
		if state.velocity.y > 16:
			anim = "falling"
		elif state.velocity.y < 0:
			anim = "jump"
	
	if $AnimationPlayer.current_animation == "shoot":
		return
	
	if $AnimationPlayer.current_animation != anim:
		$AnimationPlayer.play(anim)
		add_animation_record(anim)

func _add_record(type, payload):
	if data_record.size() < MAX_RECORD_FRAMES:
		data_record.append({"e": type, "p": payload, "t": GameData.get_time()})
		#$Label.set_text("Data: " + str(data_record.size()))

func add_movement_record():
	_add_record(RecordEvent.Move, position)

func add_animation_record(anim):
	_add_record(RecordEvent.Anim, anim)

func add_shoot_record():
	_add_record(RecordEvent.Shoot, null)


func process_ghost(delta):
	# TODO: make this timestamp based
	
	var data_line = data_record.pop_front()

	if data_line and state.dead == false:
		#{"e": type, "p": payload, "t": GameData.get_time()}
		
		# Animation frame
		if data_line.e == RecordEvent.Anim:
			if data_line.p == "jump":
				$JumpSound.play()
			
			$AnimationPlayer.play(data_line.p)
			
			#Read next line to lower delta
			data_line = data_record.pop_front() 
			if not data_line:
				return

		# Event frame
		if data_line.e == RecordEvent.Shoot:
			if state.has_bullet:
				shoot()
			
			#Read next line to lower delta
			data_line = data_record.pop_front() 
			if not data_line:
				return

		# Movement frame
		if data_line.e == RecordEvent.Move:
			if position.x > data_line.p.x:
				$SpriteHolder.scale.x = -1
			elif position.x < data_line.p.x:
				$SpriteHolder.scale.x = 1
			
			position = data_line.p
#			$Label.set_text("Pos:" + str(position))
#			$Label2.set_text("Timestamp:" + str(data_line.t))
#			$Label3.set_text("Delta:" + str(data_line.t - GameData.get_time()))

			
	else:
		state.velocity.y += DEFAULT_GRAVITY.y
		state.velocity = move_and_slide(state.velocity, Vector2(0, -1))
		self.collision_layer = 8 #collide like player


func process_ladder(delta, input_direction):
	var on_floor_or_ghost = is_on_floor_or_ghost()
	
	if state.ladder_area:
		if position.x != state.ladder_area.global_position.x:
			if position.x < state.ladder_area.global_position.x:
				position.x += LADDER_CORRECTION_SPEED*delta
			else:
				position.x -= LADDER_CORRECTION_SPEED*delta
			
			if abs(state.ladder_area.global_position.x - position.x) < 2:
				position.x = state.ladder_area.global_position.x
			return

	# Quit ladder on jump
	if Input.is_action_just_pressed("ui_jump"):
		state.current_state = PlayerState.Normal
		return
	
	# Stop movement
	if input_direction.y == 0.0:
		var stop_force = STOP_FORCE_LADDER*delta
		if state.velocity.y > 0:
			state.velocity.y = max(state.velocity.x - stop_force, 0)
		elif state.velocity.y < 0:
			state.velocity.y = min(state.velocity.x + stop_force, 0)
	# Accelarete
	else:
		state.velocity.y += input_direction.y * delta * LADDER_FORCE
		if state.velocity.y > MAX_SPEED:
			state.velocity.y = MAX_SPEED
		elif state.velocity.y < -MAX_SPEED:
			state.velocity.y = -MAX_SPEED
	
	state.velocity = move_and_slide(state.velocity, Vector2(0, -1))

func process_movement(delta, input_direction):
	var on_floor_or_ghost = is_on_floor_or_ghost()
	
	# Jumping
	if on_floor_or_ghost:
		# Reset Jump state
		state.jumping = false
		state.has_jumped = false
		state.air_time = 0
	else:
		state.air_time += 1 # TODO: use delta - anyway do we need air time? xD

	if state.bounce:
		state.velocity.y =- BOUNCE_FORCE
		state.bounce = false
	
	if state.extern_jump:
		$JumpSound.play()
		state.velocity.y =- JUMP_FORCE_EXTERNAL
		state.extern_jump = false

	if Input.is_action_just_pressed("ui_jump") and on_floor_or_ghost and not state.jumping:
		$JumpSound.play()
		state.velocity.y =- JUMP_FORCE
		state.jumping = true
		state.has_jumped = true
	
	if Input.is_action_just_pressed("ui_shoot") and state.has_bullet:
		Events.emit_signal("ammo_update", 0)
		shoot()
	
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
	
	if input_direction.x == -1:
		$SpriteHolder.scale.x = -1
	elif input_direction.x == 1:
		$SpriteHolder.scale.x = 1
	
	state.velocity.y += DEFAULT_GRAVITY.y
	state.velocity = move_and_slide(state.velocity, Vector2(0, -1))

func shoot():
	state.has_bullet = false
	var direction: int
	
	if $SpriteHolder.scale.x == -1:
		direction = Types.Direction.Right
	else:
		direction = Types.Direction.Left
	
	$ShootSound.play()
	Events.emit_signal("shoot_bullet", self, direction, $SpriteHolder/Sprite/Pos.global_position, Types.BulletType.Normal)
	$AnimationPlayer.play("shoot")
	
	# Add to records if player
	if state.ghost_no == -1:
		add_shoot_record()

func set_jump():
	state.extern_jump = true

func set_bounce():
	state.bounce = true

func die():
	state.dead = true
	check_and_remove_memory()
	$DeathSound.play()
	$AnimationPlayer.play("die")

func set_ladder_area(val):
	if val != state.ladder_area:
		state.ladder_area = val
	else:
		state.ladder_area = null
	print(state.ladder_area)

func process_restart():
	if Input.is_action_just_pressed('ui_restart') and not state.suspend_respawn:
		Events.emit_signal("play_sound", "menu_click")
		add_animation_record("idle") #reset to idle before stopping
		Events.emit_signal("ghost_dialogue_popup", funcref(self, "restart_callback"))
		check_and_remove_memory()


func restart_callback(result):
	if result:
		GameData.add_ghost(data_record)
	restart()

func check_and_remove_memory():
		if state.pickup.size() > 0:
			for pickup in state.pickup:
				var id = GameData.memory_pickup.find(pickup)
				if id != -1:
					GameData.memory_pickup.remove(id)
				else:
					printerr("pickup id not found")
			Events.emit_signal("memory_update_collected", GameData.memory_pickup.size())
			

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

func restart():
	GameData.stop_time()
	GameData.clear_time()
	GameData.restart_level()
	Events.emit_signal("restart_level")

func _on_AnimationPlayer_animation_finished(anim_name):
	print("anim finished")
	match anim_name:
		"die":
			if not is_ghost():
				restart()
			else:
				queue_free()
		"shoot":
			$AnimationPlayer.play("idle")
		_:
			pass
