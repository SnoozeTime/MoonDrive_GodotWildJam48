class_name Segment extends Reference

var index = 0
var p1: RoadPoint = null
var p2: RoadPoint = null
var color = null

# curvature
var curve = 0

func _init(n: int, c := 0):
	index = n
	p1 = RoadPoint.new()
	p1.world = Vector3(0, 0, n * Settings.SEGMENT_LENGTH)
	p2 = RoadPoint.new()
	p2.world = Vector3(0, 0, (n+1) * Settings.SEGMENT_LENGTH)

	color = Settings.COLORS_LIGHT
	if int(floor(n/Settings.RUMBLE_LENGTH)) %2 == 0:
		color = Settings.COLORS_DARK

	curve = c

func project(camera: Vector3, camera_depth):
	p1.project(camera, camera_depth)
	p2.project(camera, camera_depth)

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

	if p2.screen.y > 500 and p2.screen.y < 700:
		print("HERE")

	# The road.
	Settings.draw_rectangle(node2d, p1.screen.x, p1.screen.y, p1.screen.z, p2.screen.x, p2.screen.y, p2.screen.z, color["road"])

	if p2.screen.y > 0:
		print("HERE")
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
