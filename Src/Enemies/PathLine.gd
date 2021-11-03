extends Line2D
class_name PathLine



func _ready():
	assert(points.size() > 1) # -> PathLine requires at least two points
	
	width = 1
	hide()
