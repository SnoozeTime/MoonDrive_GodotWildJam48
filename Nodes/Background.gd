extends Node2D

onready var sky = $Sky
onready var hills = $Hills
onready var hills_back = $HillsBack
onready var sea = $Sea
var hillsBackSpeed = 0.5
var hillSpeed   = 0.8

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func adjust_offsets(speed_percent, curve):
	hills_back.position.x = hills_back.position.x+ hillsBackSpeed*speed_percent*curve #, -1, 1)
	hills.position.x = hills.position.x+ hillSpeed*speed_percent*curve #, -1, 1)
	
func set_sea_level(maxy):
	sea.global_position.y = maxy
