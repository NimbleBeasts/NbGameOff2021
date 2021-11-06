extends Node

var spawner_id = 0

# Timestamp
var timestamp = {
	"processing": false,
	"time": 0.0,
}

# Recorded ghost data
var data = []


func get_number_of_ghosts():
	return data.size()

func add_ghost(blob):
	data.append(blob)
	Events.emit_signal("ghost_added")

func clear_ghosts():
	print("Ghosts.clear_ghosts")
	data = []
	Events.emit_signal("ghost_clear")


# Timestamp

func start_time():
	timestamp.processing = true

func stop_time():
	timestamp.processing = false

func clear_time():
	timestamp.time = 0.0

func get_time():
	return timestamp.time

func _physics_process(delta):
	if timestamp.processing:
		timestamp.time += delta
