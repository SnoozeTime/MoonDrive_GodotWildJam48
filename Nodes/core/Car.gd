class_name Car
extends Reference

var sprite_name = "car01"
var z = 0
var offset = 0
var speed = 0
var index = 0
var percent = 0
var sprite_coords_x = 0
var car_width = 1.5

func _init():
    var type = randf()

    if type<0.8:
        sprite_name = "car02"
        if randf() <=0.5:
            sprite_coords_x = 1
    else:
        sprite_name = "car03"