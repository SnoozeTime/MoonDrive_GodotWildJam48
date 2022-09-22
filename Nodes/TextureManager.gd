# Class to hold all textures for a level.
extends Node
class_name TextureManager

var dict = {}
var sprite_scale = 1
var player_w = 1.0

func _ready():
	load_player()

func load_player():
	var player_texture = load("res://assets/Sprites/player.png")
	var player_sprite = MySprite.new(player_texture, 1, 8)
	dict["player"] = player_sprite
	sprite_scale = 0.3 / player_sprite.get_width()
	player_w = 0.3

	var playerlight_sprite = MySprite.new(load("res://assets/Sprites/player_lights.png"), 1, 8)
	playerlight_sprite.modulate = Color(1.8, 1.8, 1.8, 1.0)
	dict["player_lights"] = playerlight_sprite

func get_texture(name: String) -> MySprite:
	if name in dict:
		return dict[name]
	return null


func load_level1():
	dict["billboard_02"] = MySprite.new(load("res://assets/Background/billboard02.png"), 1, 1)

	dict["car02"] = MySprite.new(load("res://assets/Background/car2.png"), 1, 2)
	dict["car03"] = MySprite.new(load("res://assets/Background/car3.png"), 1, 1)
	dict["beach_right"] = MySprite.new(load("res://assets/Road/beach_right.png"), 1, 1)

	dict["boost"] = MySprite.new(load("res://assets/Background/boost.png"), 1, 4)
	dict["boost"].collision = false
	dict["boost"].boost = true
	dict["boost"].animated = true
	dict["boost"].modulate = Color(1.8, 1.8, 1.8, 1.0)

	dict["fence_left"] =  MySprite.new(load("res://assets/Road/fence_left.png"), 1, 2)

	dict["palmtree"] =  MySprite.new(load("res://assets/Road/palmtree.png"), 1, 1)
	dict["palmtree"].collider_width = 40

	dict["bush"] =  MySprite.new(load("res://assets/Background/bush.png"), 1, 1)
	dict["building1"] =  MySprite.new(load("res://assets/Road/building1.png"), 1, 1)

	dict["building2"] =  MySprite.new(load("res://assets/Road/building2.png"), 1, 4)

	dict["checkpoint"] = MySprite.new(load("res://assets/Background/checkpoint.png"), 1, 1)
	dict["checkpoint"].collision = false
	dict["bridge"] = MySprite.new(load("res://assets/Background/bridge.png"), 1, 1)
	dict["bridge"].collision = false
	dict["bridge"].modulate = Color(1.8, 1.8, 1.8, 1.0)
