extends Node2D

onready var play = $"%PlayButton"

func _ready():
	
	play.grab_focus()
	MusicManager.play_menu()


func _on_PlayButton_pressed():
	Transition.change_scene("res://Nodes/Game.tscn")


func _on_LeaderboardButton_pressed():
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	pass # Replace with function body.



func _on_ExitButton_pressed():
	get_tree().quit()

