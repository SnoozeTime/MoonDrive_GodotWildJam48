class_name RoadPoint extends Reference


var world: Vector3 = Vector3.ZERO
var screen: Vector3 = Vector3.ZERO
var camera: Vector3 = Vector3.ZERO
var screen_scale = 1

func project(camera_pos: Vector3, camera_depth):
	camera = world - camera_pos
	var scale = camera_depth/(0.01+camera.z)
	screen_scale = scale
	var width = Settings.WIDTH
	var height = Settings.HEIGHT
	screen.x = round( (width/2) + (scale*camera.x * width /2) )
	screen.y = (height/2) - (scale*camera.y * height /2)
	# screen.w
	screen.z = round(scale * Settings.ROAD_WIDTH * width /2)
