extends Area2D
class_name BaseEnemyHitzone

signal die()

export(bool) var vulnerable_to_jump = false
export(bool) var vulnerable_to_bullet = false

var parent = null

func _ready():
	parent = get_parent()
	connect("body_entered", self, "_on_BaseEnemyHitzone_body_entered")

func _on_BaseEnemyHitzone_body_entered(body):
	print("player")
	if not parent:
		return

	if not parent.state.dead:
		var contact = body.position - parent.position
		if abs(contact.x) < abs(contact.y) or body.is_ghost(): # Just to make sure we have no delta issue
			# Head first
			if vulnerable_to_jump:
				emit_signal("die")
			else:
				body.die()
		else:
			# Body first
			body.die()


func die():
	if vulnerable_to_bullet:
		emit_signal("die")
