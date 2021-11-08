extends Area2D

const BULLET_SPEED = 300

var emitter = null
var inc = 0
var alive = true

func _physics_process(delta):
	if alive:
		position.x += inc*BULLET_SPEED*delta

func shoot(player, direction, pos, type = Types.BulletType.Normal):
	emitter = player
	if direction == Types.Direction.Right:
		$Sprite.flip_h = true
		inc = -1
	else:
		inc = 1
	position = pos

func _on_Bullet_body_entered(body):
	if body == emitter:
		return
	else:
		if body.has_method("die"):
			body.die()
			
		alive = false
		$AnimationPlayer.play("explode")


func _on_Bullet_area_entered(area):
	_on_Bullet_body_entered(area)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


