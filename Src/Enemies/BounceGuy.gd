extends Area2D
class_name BounceGuy

const WALK_SPEED = 12
const FALL_SPEED = 400
const PATH_PRECISION = 1

var state = {
	"walk_to": 0,
	"walk_paused": false,
	"direction": Types.Direction.Left,
	"dead": false,
	"dead_falling": false
}

var path_points = []


func _ready():
	assert($PathLine)
	
	for point in $PathLine.get_points():
		path_points.append(point.x + position.x)

	update_direction()


func _process(delta):
	if not state.dead and not state.walk_paused:
		if state.direction == Types.Direction.Left:
			position.x -= WALK_SPEED * delta
		else:
			position.x += WALK_SPEED * delta
		
		#$Label.set_text(str(position.x))
		
		if path_points[state.walk_to] - PATH_PRECISION  <= position.x \
			and path_points[state.walk_to] + PATH_PRECISION  >= position.x:
				# Point reached - take next
				state.walk_to += 1
				if state.walk_to >= path_points.size():
					state.walk_to = 0
				
				update_direction()
	elif state.dead_falling:
		# Dead
		position.y += FALL_SPEED * delta
		
		if position.y > 2000:
			queue_free()

func update_direction():
	if path_points[state.walk_to] < position.x:
		state.direction = Types.Direction.Left
		$Sprite.flip_h = false
	else:
		state.direction = Types.Direction.Right
		$Sprite.flip_h = true

func die():
	state.dead = true
	$DeathSound.play()
	$AnimationPlayer.play("die")

func _on_BounceGuy_body_entered(body):
	if body.has_method("set_jump"):
		$PopSound.play()
		
		body.state.velocity.y = 0
		body.set_jump()

		$AnimationPlayer.play("pop")


func _on_BounceGuy_area_entered(area):
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		state.dead_falling = true
	elif anim_name == "pop":
		$AnimationPlayer.play("walk")
