extends Node

var spawner_id = 0


const message_data = [
	{"id": "tut1", "data": [
		{"char": Types.CharacterType.Tutorial, "text": "TEXT_1", "events": []},
		{"char": Types.CharacterType.Player, "text": "TEXT_2", "events": ["test_event"]},
	]}
]

# Timestamp
var timestamp = {
	"processing": false,
	"time": 0.0,
}

# Recorded ghost data
var data = []

# Store already triggered dialogues
var dialogue_nodes = []

func new_level():
	dialogue_nodes = []
	data = []
	timestamp.processing = false
	timestamp.time = 0.0
	spawner_id = 0

func get_number_of_ghosts():
	return data.size()

func add_ghost(blob):
	data.append(blob)
	Events.emit_signal("ghost_added")

func clear_ghosts():
	print("GameData.clear_ghosts")
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
