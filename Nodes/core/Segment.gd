class_name Segment extends Reference

var index = 0
var p1: RoadPoint = null
var p2: RoadPoint = null
var color = null

# curvature
var curve = 0

var clip = null

# sprites (billboards, trees...)
var sprites = []

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

func add_sprite(sprite, offset):
	sprites.append({ "sprite": sprite, "offset": offset})

func project(camera: Vector3, camera_depth, x, dx):
	p1.project(camera-Vector3(x, 0, 0), camera_depth)
	p2.project(camera-Vector3(x+dx, 0, 0), camera_depth)

func draw(node2d: Node2D):


	var r1 = Settings.rumble_width(p1.screen.z)
	var l1 = Settings.lane_marker_width(p1.screen.z)
	var r2 = Settings.rumble_width(p2.screen.z)
	var l2 = Settings.lane_marker_width(p2.screen.z)

	# grass
	var width = Settings.WIDTH
	Settings.draw_rectangle(node2d, width/2, p1.screen.y, width/2,width/2, p2.screen.y, width/2, color["grass"])

	# Rumble
	Settings.draw_rectangle(node2d, p1.screen.x-p1.screen.z-r1, p1.screen.y, r1, p2.screen.x-p2.screen.z-r2, p2.screen.y, r2, color["rumble"])
	Settings.draw_rectangle(node2d, p1.screen.x+p1.screen.z+r1, p1.screen.y, r1, p2.screen.x+p2.screen.z+r2, p2.screen.y, r2, color["rumble"])

	# The road.
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
