extends HBoxContainer
var zero = preload("res://assets/GUI/timer_0.png")
var one = preload("res://assets/GUI/timer_1.png")
var two = preload("res://assets/GUI/timer_2.png")
var three = preload("res://assets/GUI/timer_3.png")
var four = preload("res://assets/GUI/timer_4.png")
var five = preload("res://assets/GUI/timer_5.png")
var six = preload("res://assets/GUI/timer_6.png")
var seven = preload("res://assets/GUI/timer_7.png")
var eight = preload("res://assets/GUI/timer_8.png")
var nine = preload("res://assets/GUI/timer_9.png")


onready var cents_texture = $"100s"
onready var tens_texture = $"10s"
onready var ones_texture = $"1s"


func get_sprite(digit):
	match digit:
		0: return zero
		1: return one
		2: return two
		3: return three
		4: return four
		5: return five
		6: return six
		7: return seven
		8: return eight
		9: return nine

func set_timer(timer: int):
	var cent_digits = int(round(timer / 100))
	cents_texture.texture = get_sprite(cent_digits)
	var tens_digits = int(round((timer-100*cent_digits) / 10))
	tens_texture.texture = get_sprite(tens_digits)
	var ones_digits = int(round((timer-(100*cent_digits+10*tens_digits))))
	ones_texture.texture = get_sprite(ones_digits)
