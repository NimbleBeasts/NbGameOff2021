extends Area2D
class_name NormalGuy

const WALK_SPEED = 24
const FALL_SPEED = 400
const PATH_PRECISION = 1

var state = {
	"walk_to": 0,
	"direction": Types.Direction.Left,
	"dead": false,
	"dead_falling": false
}


var path_points = []


func _ready():
	$BaseEnemyHitzone.connect("die", self, "die")
	
	assert($PathLine)
	
	for point in $PathLine.get_points():
		path_points.append(point.x + position.x)

	update_direction()


func _process(delta):
	if not state.dead:
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
		$Sprite.flip_h = true
	else:
		state.direction = Types.Direction.Right
		$Sprite.flip_h = false

func die():
	state.dead = true
	$AnimationPlayer.play("die")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		state.dead_falling = true
