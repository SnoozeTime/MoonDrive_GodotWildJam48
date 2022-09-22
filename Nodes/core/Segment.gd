class_name Segment extends Reference

var index = 0
var p1: RoadPoint = null
var p2: RoadPoint = null
var color = null


var left_side = SIDE_TYPE.BaseColor
var right_side = SIDE_TYPE.BaseColor

enum SIDE_TYPE {
	BaseColor, 
	Beach,
	Water,
	None,
	City,
}

# A color to show on the floor (e.g. start/checkpoint)
var floor_indication = null

# curvature
var curve = 0
var looped = false
var clip = null

var clamp_x = Vector2(-2, 2)

# sprites (billboards, trees...)
var sprites = []

# Current cars on that segment
var cars = []

func _init(p1_y, p2_y, n: int, c := 0):
	index = n
	p1 = RoadPoint.new()
	p1.world = Vector3(0, p1_y, n * Settings.SEGMENT_LENGTH)
	p2 = RoadPoint.new()
	p2.world = Vector3(0, p2_y, (n+1) * Settings.SEGMENT_LENGTH)

	color = Settings.COLORS_LIGHT
	if int(floor(n/Settings.RUMBLE_LENGTH)) %2 == 0:
		color = Settings.COLORS_DARK

	curve = c

func add_sprite(sprite, offset, sprite_coords = Vector2.ZERO):
	sprites.append({ "sprite": sprite, "offset": offset, "sprite_coords": sprite_coords})

func project(camera: Vector3, camera_depth, x, dx, track_length):

	var camera_z_offset = 0
	if looped:
		camera_z_offset = track_length
	p1.project(camera-Vector3(x, 0, camera_z_offset), camera_depth)
	p2.project(camera-Vector3(x+dx, 0, camera_z_offset), camera_depth)

func draw(node2d: Node2D, texture_manager: TextureManager):


	var r1 = Settings.rumble_width(p1.screen.z)
	var l1 = Settings.lane_marker_width(p1.screen.z)
	var r2 = Settings.rumble_width(p2.screen.z)
	var l2 = Settings.lane_marker_width(p2.screen.z)

	# Side of the road

	match left_side:
		SIDE_TYPE.None: pass
		SIDE_TYPE.BaseColor: draw_color_left(node2d, color["grass"])
		SIDE_TYPE.City: draw_color_left(node2d, Color.black)
		SIDE_TYPE.Beach: 
			pass # no beach on the left

	match right_side:
		SIDE_TYPE.None: pass
		SIDE_TYPE.BaseColor: draw_color_right(node2d, color["grass"])
		SIDE_TYPE.City: draw_color_right(node2d, Color.black)
		SIDE_TYPE.Beach: 
			draw_beach_right(node2d, texture_manager)

	var rumble_color = color["rumble"]
	rumble_color.r *= 2
	rumble_color.g *= 2
	rumble_color.b *= 2
	Settings.draw_rectangle(node2d, p1.screen.x-p1.screen.z-r1, p1.screen.y, r1, p2.screen.x-p2.screen.z-r2, p2.screen.y, r2, rumble_color)
	Settings.draw_rectangle(node2d, p1.screen.x+p1.screen.z+r1, p1.screen.y, r1, p2.screen.x+p2.screen.z+r2, p2.screen.y, r2, rumble_color)

	# The road.
	if floor_indication != null:
		Settings.draw_rectangle(node2d, p1.screen.x, p1.screen.y, p1.screen.z, p2.screen.x, p2.screen.y, p2.screen.z,floor_indication)
	else:
		Settings.draw_rectangle(node2d, p1.screen.x, p1.screen.y, p1.screen.z, p2.screen.x, p2.screen.y, p2.screen.z, color["road"])

	var lanes = Settings.LANES

	if "lane" in color:
		var lane_w1 = p1.screen.z * 2/lanes
		var lane_w2 = p2.screen.z * 2/lanes

		# first lane
		var lane_x1 = p1.screen.x - p1.screen.z + lane_w1
		var lane_x2 = p2.screen.x - p2.screen.z + lane_w2

		# 3 lanes -> 2 markers
		for _i in range(1, lanes):
			Settings.draw_rectangle(node2d, lane_x1, p1.screen.y, l1, lane_x2, p2.screen.y, l2, color["lane"])
			lane_x1 += lane_w1
			lane_x2 += lane_w2


func add_car(car):
	cars.append(car)

func remove_car(car):
	var idx = cars.find(car)
	if idx == -1:
		print("NOT FOUND")
	else:
		cars.remove(idx)


func draw_color_left(node2d, c):


	# Water width = width/2 - (p1.x + p1.z)
	var water_w1 = p1.screen.x-p1.screen.z
	var water_x1 = water_w1/2

	var water_w2 = p2.screen.x-p2.screen.z
	var water_x2 = water_w2/2

	Settings.draw_rectangle(node2d, water_x1, p1.screen.y, water_w1/2, water_x2, p2.screen.y, water_w2/2, c)



func draw_color_right(node2d, c):


	# right point is width
	# left point is p1.screen.x+p1.screen.z
	# x = (p1.screen.x+p1.screen.z+width)/KEY_2
	# w = width - (p1.screen.x+p1.screen.z)

	var width = Settings.WIDTH

	# Water width = width/2 - (p1.x + p1.z)
	var water_x1 = (p1.screen.x+p1.screen.z+width)/2
	var water_w1 = width-(p1.screen.x+p1.screen.z)
	var water_x2 = (p2.screen.x+p2.screen.z+width)/2
	var water_w2 = width-(p2.screen.x+p2.screen.z)

	Settings.draw_rectangle(node2d, water_x1, p1.screen.y, water_w1/2, water_x2, p2.screen.y, water_w2/2, c)


func draw_only_water(node2d, width):
	Settings.draw_rectangle(node2d, width/2, p1.screen.y, width/2,width/2, p2.screen.y, width/2, color["water"])

func draw_beach_right(node2d, texture_manager):
	#draw_color_right(node2d, color["water"])
	var beach_width = 700

	# beach ration is 1/4 beach and 3/4 water

	var beach_w1 = beach_width*p1.screen_scale*Settings.WIDTH/2*Settings.ROAD_WIDTH*texture_manager.sprite_scale
	var beach_x1 = p1.screen.x+p1.screen.z+beach_w1/2

	var beach_w2 = beach_width*p2.screen_scale*Settings.WIDTH/2*Settings.ROAD_WIDTH*texture_manager.sprite_scale
	var beach_x2 = p2.screen.x+p2.screen.z+beach_w2/2

	Settings.draw_rectangle(node2d, beach_x1, p1.screen.y, beach_w1/2, beach_x2, p2.screen.y, beach_w2/2, Color.brown)
