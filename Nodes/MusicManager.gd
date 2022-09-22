extends Node
 

onready var menu_player: AudioStreamPlayer = $MenuPlayer
onready var level_player: AudioStreamPlayer = $LevelPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_menu():
	if level_player.playing:
		fade_out_and_play(level_player, menu_player)
	else:
		play(menu_player, null)

func play_level():
	if menu_player.playing:
		fade_out_and_play(menu_player, level_player)
	else:
		play(level_player, null)

func fade_out_and_play(fade_out: AudioStreamPlayer, to_play: AudioStreamPlayer):
	var TW = get_tree().create_tween()
	TW.tween_property(fade_out, "volume_db", -60.0, 1)
	TW.tween_callback(self, "play", [to_play, fade_out])


func play(player, to_stop):
	if to_stop != null:
		to_stop.stop()
	if not player.playing:
		player.play()
		player.volume_db = -60
		var TW = get_tree().create_tween()
		TW.tween_property(player, "volume_db", 0.0, 1)
