extends KinematicBody2D


export(Types.Direction) var direction = Types.Direction.Top
export(int) var tiles = 3

const SPEED_PER_TILE = 0.5


var tween_values = [Vector2(), Vector2()] 


func _ready():
	tween_values[0] = position
	match direction:
		Types.Direction.Top:
			tween_values[1] = Vector2(position.x, position.y - tiles * 8)
		Types.Direction.Down:
			tween_values[1] = Vector2(position.x, position.y + tiles * 8)
		Types.Direction.Left:
			tween_values[1] = Vector2(position.x - tiles * 8, position.y)
		Types.Direction.Right:
			tween_values[1] = Vector2(position.x + tiles * 8, position.y)
	tween_start()

func tween_start():
	$Tween.remove_all()
	var time: float = SPEED_PER_TILE * tiles
	
	match direction:
		Types.Direction.Top, Types.Direction.Down:
			time *= (1 - (position.y - tween_values[0].y) / (tween_values[1].y - tween_values[0].y))
		_: #Types.Direction.Left, Types.Direction.Right
			time *= (1 - (position.x - tween_values[0].x) / (tween_values[1].x - tween_values[0].x))

	$Tween.interpolate_property(
		self,
		"position",
		position,
		tween_values[1],
		max(time, 0.01),
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	$Tween.start()
	
	#TODO: dont think this tween stuff will work - better do it manually


func _on_Tween_tween_all_completed():
	tween_values.invert()
	tween_start()
