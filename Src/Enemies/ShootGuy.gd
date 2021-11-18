extends Node2D

const FALL_SPEED = 400

var state = {
	"dead": false,
	"dead_falling": false,
}


func _ready():
	$AnimationPlayer.play("RESET")
	$BaseEnemyHitzone.connect("die", self, "_die")
	
	$ShootTimer.start()

func _physics_process(delta):
	if state.dead_falling:
		position.y += FALL_SPEED * delta

func die():
	pass

func _die():
	state.dead = true
	$DeathSound.play()
	$AnimationPlayer.play("die")

func shoot():
	var direction: int
	
	if self.scale.x == 1:
		direction = Types.Direction.Right
	else:
		direction = Types.Direction.Left
	
	$ShootSound.play()
	Events.emit_signal("shoot_bullet", self, direction, $Position2D.global_position, Types.BulletType.Plasma)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "preshoot":
		shoot()
		$AnimationPlayer.play("postshoot")
	elif anim_name == "die":
		state.dead_falling = true

func _on_ShootTimer_timeout():
	if not state.dead:
		$AnimationPlayer.play("preshoot")
		$ShootTimer.start()
