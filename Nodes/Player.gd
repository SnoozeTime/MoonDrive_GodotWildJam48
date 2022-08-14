extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var camera_scale = 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position.x = 1024/2
	global_position.y = 768
