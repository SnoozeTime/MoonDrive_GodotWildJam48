extends Node2D


onready var music_slider = $"%MusicSlider"
onready var sfx_slider = $"%SFXSlider"


onready var music_bus = AudioServer.get_bus_index("Music")
onready var sfx_bus = AudioServer.get_bus_index("SFX")


func _ready():
	music_slider.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


const max_db = 0
const min_db = -40



func _on_MusicSlider_drag_ended(value_changed):
	if value_changed:
		# if value =0, then min_db, if 100, then max_db
		var new_volume = lerp(min_db, max_db, float(music_slider.value)/100.0)
		AudioServer.set_bus_volume_db(music_bus, new_volume)


func _on_SFXSlider_drag_ended(value_changed):
	if value_changed:
		# if value =0, then min_db, if 100, then max_db
		var new_volume = lerp(min_db, max_db, float(sfx_slider.value)/100.0)
		AudioServer.set_bus_volume_db(sfx_bus, new_volume)


func _on_MusicToggle_toggled(button_pressed):
	AudioServer.set_bus_mute(music_bus, not button_pressed)


func _on_SFXToggle_toggled(button_pressed):
	AudioServer.set_bus_mute(sfx_bus, not button_pressed)


func _on_ShaderCheckbox_toggled(button_pressed):
	print(button_pressed)
	Settings.retro_effect = button_pressed


func _on_BackButton_pressed():
	Transition.change_scene("res://Screens/screen_main.tscn")
