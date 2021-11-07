extends KinematicBody2D
class_name FallGuy

const DEFAULT_GRAVITY = Vector2(0, 40)
const FALL_SPEED = 400

var state = {
	"walk_to": 0,
	"direction": Types.Direction.Left,
	"dead": false,
	"dead_falling": false,
	"falling": false,
	"velocity": Vector2(0, 0),
	"triggered": false,
}


func _ready():
	$AnimationPlayer.play("RESET")
	$BaseEnemyHitzone.connect("die", self, "die")

func _physics_process(delta):
	if state.dead_falling:
		position.y += FALL_SPEED * delta
	elif state.falling:
		state.velocity.y += DEFAULT_GRAVITY.y
		state.velocity = move_and_slide(state.velocity, Vector2(0, -1))
		
		if is_on_floor():
			state.falling = false
			$AnimationPlayer.play("idle")
	
	if position.y > 2000:
		queue_free()
		


func die():
	state.dead = true
	$AnimationPlayer.play("die")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "die":
		state.dead_falling = true
	elif anim_name == "awake":
		state.falling = true


func _on_DetectPlayerArea_body_entered(body):
	if not state.triggered:
		state.triggered = true
		$Sprite.frame = 1
		$AnimationPlayer.play("awake")
	
