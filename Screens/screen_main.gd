extends Node2D

onready var score = $"%ScoreLabel"
onready var play = $"%PlayButton"

func _ready():
	ScoreManager.load_from_file()

	var best = ScoreManager.current_best
	if best != null:
		var time = best.total_time
		var minutes = time / 60
		var seconds = time % 60
		score.text = "Best score: %02d'%02d'" % [minutes, seconds]
	else:
		score.hide()
	
	play.grab_focus()
	MusicManager.play_menu()


func _on_PlayButton_pressed():
	Transition.change_scene("res://Nodes/Game.tscn")


func _on_LeaderboardButton_pressed():
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	Transition.change_scene("res://Screens/screen_settings.tscn")



func _on_ExitButton_pressed():
	get_tree().quit()

