extends CenterContainer

signal go_back
var finished = false


func show_gameover_screen():
	show()
	finished = true

func _input(event):
	if finished:
		if event is InputEventKey and event.pressed:
			emit_signal("go_back")
			
		if event is InputEventJoypadButton and event.pressed:
			emit_signal("go_back")

