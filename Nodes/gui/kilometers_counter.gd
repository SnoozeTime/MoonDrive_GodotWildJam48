extends HBoxContainer

var zero = preload("res://assets/GUI/km_0.png")
var one = preload("res://assets/GUI/km_1.png")
var two = preload("res://assets/GUI/km_2.png")
var three = preload("res://assets/GUI/km_3.png")
var four = preload("res://assets/GUI/km_4.png")
var five = preload("res://assets/GUI/km_5.png")
var six = preload("res://assets/GUI/km_6.png")
var seven = preload("res://assets/GUI/km_7.png")
var eight = preload("res://assets/GUI/km_8.png")
var nine = preload("res://assets/GUI/km_9.png")


onready var cents_texture = $"100s"
onready var tens_texture = $"10s"
onready var ones_texture = $"1s"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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

func set_kilo(km: int):
	var cent_digits = int(round(km / 100))
	cents_texture.texture = get_sprite(cent_digits)
	var tens_digits = int(round((km-100*cent_digits) / 10))
	tens_texture.texture = get_sprite(tens_digits)
	var ones_digits = int(round((km-(100*cent_digits+10*tens_digits))))
	ones_texture.texture = get_sprite(ones_digits)
