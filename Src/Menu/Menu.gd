extends Control

enum MenuState {Main, Selection, Settings}
const flags = ["en","de"]

var selection_page = 0


func _ready():
	# Event Hooks
	Events.connect("menu_back", self, "_back")
	Events.connect("cfg_switch_fullscreen", self, "_switchFullscreen")

	$Main/Version.set_text(Global.getVersionString())

	# Set Language
	TranslationServer.set_locale(Global.userConfig.language)
	$Main/ButtonLanguage/Sprite.frame = flags.find(TranslationServer.get_locale())

	switchTo(MenuState.Main)
	$LevelSelection/ResetWindow.hide()


	#Populate Resolution List
	for res in Global.supportedResolutions:
		$Settings/TabContainer/Graphics/ResolutionList.add_item(" " + str(res.x) + "x" + str(res.y))
		
		var resolution = Vector2(Global.userConfig.resolution.w, Global.userConfig.resolution.h)
		if resolution == res:
			var id = $Settings/TabContainer/Graphics/ResolutionList.get_item_count() - 1
			$Settings/TabContainer/Graphics/ResolutionList.select(id, true)


#func _process(delta):
#	# Changing window size results in nullptr execption and ugly text glitches - so we overwrite it 
#	# TODO: bug report on github
#
#	# Main Buttons
#	$Main/ButtonPlay.text = "0"
#	$Main/ButtonPlay.text = tr("M_PLAY")
#	$Main/ButtonSettings.text = "0"
#	$Main/ButtonSettings.text = tr("M_SETTINGS")
#	$Main/ButtonExit.text = "0"
#	$Main/ButtonExit.text = tr("M_EXIT")
#
#	# Resolution Window
#	$Settings/TabContainer/Graphics/ApplyButton.text = "0"
#	$Settings/TabContainer/Graphics/ApplyButton.text = tr("M_APPLY")
#	var text = $Settings/TabContainer/Graphics/FullscreenButton.text
#	$Settings/TabContainer/Graphics/FullscreenButton.text = "0"
#	$Settings/TabContainer/Graphics/FullscreenButton.text = text
#
#	$Settings/BackButton.text = "0"
#	$Settings/BackButton.text = tr("M_BACK")
	
	
# Menu State Transition
func switchTo(to):
	hideAllMenuScenes()

	match to:
		MenuState.Main:
			$Main.show()
			$Main/ButtonPlay.grab_focus()
		MenuState.Selection:
			update_selection()
			$LevelSelection.show()
		MenuState.Settings:
			updateSettings()
			$Settings.show()
			# TODO: grab focus
		_:
			print("Invalid menu state")



# Selection Stuff
func update_selection():
	var level_count = Global.levels.size()
	var i = 0
	
	
	for tile in $LevelSelection/SelectionHolder.get_children():
		var level_id = i + selection_page * 3
		i += 1
	
		if level_id < level_count:
			if level_id <= Global.userConfig.unlocked_level:
				tile.set_level(level_id, Types.MenuLevelSelectionType.Normal)
			else:
				tile.set_level(level_id, Types.MenuLevelSelectionType.Locked)
		else:
			tile.set_level(-1, Types.MenuLevelSelectionType.Void)
	
	# this is called, even if we switch language
	$LevelSelection/ResetWindow/WarningLabel.bbcode_text = tr("M_DELETE_WARNING")

	
	# De(Activate) buttons
	$LevelSelection/PastButton.disabled = false
	$LevelSelection/NextButton.disabled = false
	if selection_page == 0:
		$LevelSelection/PastButton.disabled = true
	if selection_page >= (level_count - 1) / 3:
		$LevelSelection/NextButton.disabled = true

	
# Helper function for State Transition
func hideAllMenuScenes():
	# Add menu scenes here
	$Main.hide()
	$Settings.hide()
	$LevelSelection.hide()

# Helper function to update the config labels
func updateSettings():
	$Settings/TabContainer/Sounds/SoundSlider.value = Global.userConfig.soundVolume
	$Settings/TabContainer/Sounds/SoundSlider/Value.set_text(str(Global.userConfig.soundVolume*10) + "%")

	$Settings/TabContainer/Sounds/MusicSlider.value = Global.userConfig.musicVolume
	$Settings/TabContainer/Sounds/MusicSlider/Value.set_text(str(Global.userConfig.musicVolume*10) + "%")

	$Settings/TabContainer/Shader/GlitchShader.pressed = Global.userConfig.glitch
	$Settings/TabContainer/Shader/MatrixShader.pressed = Global.userConfig.moving_bg
	
#	$Settings/TabContainer/General/BrightnessSlider.value = Global.userConfig.brightness
#	$Settings/TabContainer/General/BrightnessSlider/Value.set_text("%.2f" % Global.userConfig.brightness)
#
#	$Settings/TabContainer/General/ContrastSlider.value = Global.userConfig.contrast
#	$Settings/TabContainer/General/ContrastSlider/Value.set_text("%.2f" % Global.userConfig.brightness)
#

	if Global.userConfig.fullscreen:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "On"
	else:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "Off"

###############################################################################
# Callbacks
###############################################################################

# Event Hook
func _switchSound(_val):
	updateSettings()

# Event Hook
func _switchMusic(_val):
	updateSettings()

# Event Hook
func _switchFullscreen(_val):
	updateSettings()

# Event Hook
func _back():
	switchTo(MenuState.Main)
	Events.emit_signal("play_sound", "menu_click")


func _on_PastButton_button_up():
	selection_page -= 1
	update_selection()
	Events.emit_signal("play_sound", "menu_click")

func _on_NextButton_button_up():
	selection_page += 1
	update_selection()
	Events.emit_signal("play_sound", "menu_click")
	

func _on_ButtonPlay_button_up():
	switchTo(MenuState.Selection)
	Events.emit_signal("play_sound", "menu_click")


func _on_ButtonSettings_button_up():
	switchTo(MenuState.Settings)
	Events.emit_signal("play_sound", "menu_click")


func _on_ButtonExit_button_up():
	print("Ok, Bye! Thanks for playing.")
	get_tree().quit()


func _on_BackButton_button_up():
	switchTo(MenuState.Main)
	Events.emit_signal("play_sound", "menu_click")


func _on_FullscreenButton_button_up():
	if not Global.userConfig.fullscreen:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "On"
	else:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "Off"
		
	Events.emit_signal("cfg_switch_fullscreen", !Global.userConfig.fullscreen)

#	# Glitchy font on resize workaround
#	$Settings/TabContainer/Graphics/ResolutionList.rect_scale = Vector2(1.1, 1.1)
#	yield(get_tree().create_timer(0.001), "timeout")
#	$Settings/TabContainer/Graphics/ResolutionList.rect_scale = Vector2(1.0, 1.0)
#	Events.emit_signal("play_sound", "menu_click")


func _on_ApplyButton_button_up():
	var id = $Settings/TabContainer/Graphics/ResolutionList.get_selected_items()[0]
	Global.setResolution(id)
	
#	# Glitchy font on resize workaround
#	$Settings/TabContainer/Graphics/ResolutionList.rect_scale = Vector2(1.1, 1.1)
#	yield(get_tree().create_timer(0.001), "timeout")
#	$Settings/TabContainer/Graphics/ResolutionList.rect_scale = Vector2(1.0, 1.0)
#	Events.emit_signal("play_sound", "menu_click")


func _on_SoundSlider_value_changed(value):
	$Settings/TabContainer/Sounds/SoundSlider/Value.set_text(str(value*10) + "%")
	Events.emit_signal("cfg_sound_set_volume", value)
	Events.emit_signal("play_sound", "menu_click")


func _on_MusicSlider_value_changed(value):
	$Settings/TabContainer/Sounds/MusicSlider/Value.set_text(str(value*10) + "%")
	Events.emit_signal("cfg_music_set_volume", value)
	Events.emit_signal("play_sound", "menu_click")


func _on_BrightnessSlider_value_changed(value):
	$Settings/TabContainer/General/BrightnessSlider/Value.set_text("%.2f" % value)
	Events.emit_signal("cfg_change_brightness", value)
	Events.emit_signal("play_sound", "menu_click")


func _on_ContrastSlider_value_changed(value):
	$Settings/TabContainer/General/ContrastSlider/Value.set_text("%.2f" % value)
	Events.emit_signal("cfg_change_contrast", value)
	Events.emit_signal("play_sound", "menu_click")


func _on_ButtonLanguage_button_up():
	var availableLocale = TranslationServer.get_loaded_locales()
	var id = availableLocale.find(TranslationServer.get_locale()) + 1
	
	if id >= availableLocale.size():
		id = 0
	
	TranslationServer.set_locale(availableLocale[id])
	$Main/ButtonLanguage/Sprite.frame = flags.find(TranslationServer.get_locale())
	
	Global.userConfig.language = TranslationServer.get_locale()
	Global.saveConfig()
	Events.emit_signal("play_sound", "menu_click")
	print("Language: " + tr("TEST_ENTRY"))





func _on_SelectionTile1_button_up():
	var level = selection_page*3
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("load_level", level)


func _on_SelectionTile2_button_up():
	var level = selection_page*3 + 1
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("load_level", level)


func _on_SelectionTile3_button_up():
	var level = selection_page*3 + 2
	Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("load_level", level)



func _on_ResetButton_button_up():
	$LevelSelection/ResetWindow.show()
	$LevelSelection/ResetWindow/ResetBackButton.grab_focus()
	Events.emit_signal("play_sound", "menu_click")


func _on_ResetDeleteButton_button_up():
	$LevelSelection/ResetWindow.hide()
	Global.userConfig.unlocked_level = 0
	Global.saveConfig()
	update_selection()
	Events.emit_signal("play_sound", "menu_click")


func _on_ResetBackButton_button_up():
	$LevelSelection/ResetWindow.hide()
	$LevelSelection/SelectionHolder/SelectionTile1/Title.grab_focus()
	Events.emit_signal("play_sound", "menu_click")


func _on_GlitchShader_toggled(button_pressed):
	Global.userConfig.glitch = button_pressed
	Global.saveConfig()
	Events.emit_signal("shader_glitch", button_pressed)


func _on_MatrixShader_toggled(button_pressed):
	Global.userConfig.moving_bg = button_pressed
	Global.saveConfig()
	Events.emit_signal("shader_matrix", button_pressed)
