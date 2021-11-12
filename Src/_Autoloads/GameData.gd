extends Node

var spawner_id = 0


const message_data = [
	{"id": "TUT1", "data": [
		{"char": Types.CharacterType.Professor, "text": "TUT1_TEXT_1", "events": []},
		{"char": Types.CharacterType.Subject, "text": "TUT1_TEXT_2", "events": []},
		{"char": Types.CharacterType.Professor, "text": "TUT1_TEXT_3", "events": []},
		{"char": Types.CharacterType.Subject, "text": "TUT1_TEXT_4", "events": []},
		{"char": Types.CharacterType.Professor, "text": "TUT1_TEXT_5", "events": []},
	]},
	{"id": "TUT2", "data": [
		{"char": Types.CharacterType.Professor, "text": "TUT2_TEXT_1", "events": []},
		{"char": Types.CharacterType.Subject, "text": "TUT2_TEXT_2", "events": []},
	]},
	{"id": "TUT3", "data": [
		{"char": Types.CharacterType.Professor, "text": "TUT3_TEXT_1", "events": []},
		{"char": Types.CharacterType.Subject, "text": "TUT3_TEXT_2", "events": ["tutorial_step3_completed"]},
	]},
	{"id": "TUT4", "data": [
		{"char": Types.CharacterType.Professor, "text": "TUT4_TEXT_1", "events": []},
		{"char": Types.CharacterType.Professor, "text": "TUT4_TEXT_2", "events": []},
		{"char": Types.CharacterType.Subject, "text": "TUT4_TEXT_3", "events": []},
		{"char": Types.CharacterType.Professor, "text": "TUT4_TEXT_4", "events": []},
		{"char": Types.CharacterType.Marc, "text": "TUT4_TEXT_5", "events": []},
		{"char": Types.CharacterType.Professor, "text": "TUT4_TEXT_6", "events": []},
	]},
]

# Timestamp
var timestamp = {
	"processing": false,
	"time": 0.0,
}

var tutorial_state_3 = false

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
	tutorial_state_3 = false

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
