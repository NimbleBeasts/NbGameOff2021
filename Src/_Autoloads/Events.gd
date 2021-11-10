extends Node

#warning-ignore-all:unused_signal

const DEBUG_OUTPUT_ON_SIGNAL_CONNECT = false

###############################################################################
# Global Signal List
###############################################################################

# Level Management
signal new_game() #not used
signal load_level(id)
signal restart_level()

# Ghost Signals
signal ghost_added()
signal ghost_clear()
signal ghost_spawn(id)
signal ghost_dialogue_popup(callback)
signal ghost_set_spawner(id)

# Dialogue
signal dialogue_popup(character, text, last_diag, callback)

signal test_event()


# Bullet
signal shoot_bullet(player, direction, pos, type)

# Sound
signal play_sound(sound, volume, pos)
# Music
signal play_music(track)
signal change_music(track_id)
# Menu Related
signal menu_back()

###########################################################################
# Config Changes
###########################################################################
## Emitted if sound volume is changed in menus
signal cfg_sound_set_volume(new)
## Emitted if music volume is changed in menus
signal cfg_music_set_volume(new)
## Emitted if fullscreen mode is changed in menus
signal cfg_switch_fullscreen(value)
## Emitted if the brightness is changed in menus
signal cfg_change_brightness(value)
## Emitted if the contrast is changed in menus
signal cfg_change_contrast(value)

