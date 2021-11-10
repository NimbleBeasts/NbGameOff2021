extends Node2D



var tracks = [
	preload("res://Assets/Music/01_main_theme-super-secret-theme.mp3"),
	load("res://Assets/Music/06_tutorial-lugn-techno.mp3"),
	load("res://Assets/Music/02_normal_1-dont-be-a-bitch.mp3"),
	load("res://Assets/Music/04_fast_1-delicious-keys.mp3"),
]
var music_id_playing = 0

onready var musicPlayer: AudioStreamPlayer = $Music
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sounds_bus = AudioServer.get_bus_index("Sound")
func _ready():
	# Initial Set Volumes
	setMusicVolume(Global.userConfig.musicVolume)
	setSoundVolume(Global.userConfig.soundVolume)
	# Event Hooks
	Events.connect("play_sound", self, "_playSound")
	Events.connect("play_music", self, "onPlayMusic")
	Events.connect("change_music", self, "_change_music")
	
	Events.connect("cfg_music_set_volume", self, "setMusicVolume")
	Events.connect("cfg_sound_set_volume", self, "setSoundVolume")


###############################################################################
# Callbacks
###############################################################################

func setMusicVolume(value):
	if value == 0:
		$Music.stop()
	else:
		$Music.play()
	AudioServer.set_bus_volume_db(music_bus, linear2db(float(value)/10))

func setSoundVolume(value):
	AudioServer.set_bus_volume_db(sounds_bus, linear2db(float(value)/10))
	

# Event Hook: Play a sound
func _playSound(sound: String, _volume : float = 1.0, _pos : Vector2 = Vector2(0, 0)):
	if Global.userConfig.soundVolume > 0:
		match sound:
			"menu_click":
				$MenuClick.play()
			"example":
				$Example2D.volume_db = -20 + 12 * _volume
				$Example2D.position = _pos
				$Example2D.play()
			_:
				print("error: sound not found - name: " + str(sound))

func _change_music(music_id):
	if music_id_playing != music_id:
		music_id_playing = music_id
		$Music.stop()
		$Music.stream = tracks[music_id]
		$Music.play()

# Music Loop?
func onPlayMusic(music_id) -> void:

	pass # Replace with function body.
