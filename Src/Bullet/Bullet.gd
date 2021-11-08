extends Area2D

const BULLET_SPEED = 300

var bullet_texture = [preload("res://Assets/Bullet/Bullet.png"), preload("res://Assets/Bullet/Plasma.png")]

var emitter = null
var inc = 0
var alive = true

func _physics_process(delta):
	if alive:
		position.x += inc*BULLET_SPEED*delta

func shoot(player, direction, pos, type = Types.BulletType.Normal):
	emitter = player
	if direction == Types.Direction.Right:
		$Projectile.scale.x = -1
		$Explosion.scale.x = -1
		inc = -1
	else:
		inc = 1
	position = pos
	$Projectile.texture = bullet_texture[type]
	
	$Projectile.show()
	$Explosion.hide()

func _on_Bullet_body_entered(body):
	if body == emitter:
		return
	else:
		if body.has_method("die"):
			body.die()
		
		$Projectile.hide()
		$Explosion.show()
		
		alive = false
		$AnimationPlayer.play("explode")


func _on_Bullet_area_entered(area):
	_on_Bullet_body_entered(area)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


