extends Node2D



onready var player = $Player

# https://codeincomplete.com/articles/javascript-racer-v1-straight/

var width = 1024
var height = 768
var segments = [] # array of road segments

var fov = 100
var road_width = 2000 # half-width (-road_witdh to +road_width)
var segment_length = 200 # length of single segment
var rumble_length = 3 # number of segments per red/white strip
var track_length = 0 # To update later - length of entire track
var lanes         = 3;                      # number of lanes
var fieldOfView   = 100;                    #/ angle (degrees) for field of view
var cameraHeight  = 1000;                   # z height of camera
var cameraDepth   =  1 / tan((fieldOfView/2) * PI/180)                   # z distance camera is from screen (computed)
var drawDistance  = 300;                    #number of segments to draw

var position_z = 1

var player_x = 0
var max_speed = segment_length * 60
var accel = max_speed/5
var decel = max_speed/5
var braking = max_speed
var speed = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_z = cameraHeight*cameraDepth


const COLORS_LIGHT = {
	"road": Color("#6B6B6B"),
	"grass": Color("#10AA10"),
	"rumble": Color("#555555"),
	"lane": Color('#CCCCCC')
}

const COLORS_DARK = {
	"road": Color("#696969"),
	"grass": Color("#009A00"),
	"rumble": Color("#BBBBBB")
}



# Called when the node enters the scene tree for the first time.
func _ready():
	reset_road()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	# Z position
	increase_pos(delta)

	# X position
	var dx = delta * 2 * (speed/max_speed)
	if Input.is_action_pressed("steer_left"):
		player_x -= dx
	elif Input.is_action_pressed("steer_right"):
		player_x += dx
	player_x = clamp(player_x, -2, 2)


	# Update the speed
	if Input.is_action_pressed("accelerate"):
		speed += accel *  delta
	elif Input.is_action_pressed("brake"):
		speed -= braking * delta
	else:
		speed -= decel * delta
	speed = clamp(speed, 0, max_speed)
	
	player.camera_scale = cameraDepth / player_z

	# Draw screen
	update()

func increase_pos(delta):
	var res = position_z + delta * speed
	
	while res >= track_length:
		res -= track_length

	while res < 0:
		res += track_length

	position_z = res


func reset_road():

	segments = []

	for n in range(500):
		var c = COLORS_LIGHT
		if int(floor(n/rumble_length)) %2 == 0:
			c = COLORS_DARK

		segments.append(Segment.new(n))
		# 	{
		# 	"index": n,
		# 	"p1": { "world": Vector3(0, 0, n * segment_length), "screen": Vector3.ZERO, "camera": Vector3.ZERO},
		# 	"p2": { "world": Vector3(0, 0, (n+1) * segment_length), "screen": Vector3.ZERO, "camera": Vector3.ZERO},
		# 	"color": c
		# })
	track_length = segments.size()*segment_length


func add_segment(curve):
	var n = segments.size()
	var c = COLORS_LIGHT
	if int(floor(n/rumble_length)) %2 == 0:
		c = COLORS_DARK
	
	segments.append({
		"index": n,
		"p1": { "world": Vector3(0, 0, n * segment_length), "screen": Vector3.ZERO, "camera": Vector3.ZERO},
		"p2": { "world": Vector3(0, 0, (n+1) * segment_length), "screen": Vector3.ZERO, "camera": Vector3.ZERO},
		"color": c,
		"curve": curve
	})

func find_segment(z):
	return segments[int(floor(z/segment_length))%segments.size()]
	
func _draw():

	var base_segment = find_segment(position_z)
	var camera_pos = Vector3(player_x * road_width, cameraHeight, position_z)
	#var maxy = height
	for n in range(drawDistance):
		
		var segment = segments[(base_segment.index+n) % segments.size()]
		segment.project(camera_pos, cameraDepth)
		#project(segment.p1, camera_pos)
		#project(segment.p2, camera_pos)

		# CLIP
		if segment.p1.camera.z <= cameraDepth: # or segment["p2"]["screen"].z >= maxy:
			continue

		# Render the segment
		segment.draw(self)

func project(p, camera: Vector3):
	p["camera"] = p["world"] - camera
	var scale = cameraDepth/p["camera"].z
	p["screen_scale"] = scale
	p["screen"].x = round( (width/2) + (scale*p["camera"].x * width /2) )
	p["screen"].y = round( (height/2) - (scale*p["camera"].y * height /2) )
	# screen.w
	p["screen"].z = round(scale * road_width * width /2)


func draw_segment(segment):


	var p1_screen = segment["p1"]["screen"]
	var p2_screen = segment["p2"]["screen"]

	var r1 = rumble_width(p1_screen.z)
	var l1 = lane_marker_width(p1_screen.z)
	var r2 = rumble_width(p2_screen.z)
	var l2 = lane_marker_width(p2_screen.z)

	# grass
	Settings.draw_rectangle(self, width/2, p1_screen.y, width/2,width/2, p2_screen.y, width/2, segment["color"]["grass"])

	# Rumble
	Settings.draw_rectangle(self, p1_screen.x-p1_screen.z-r1, p1_screen.y, r1, p2_screen.x-p2_screen.z-r2, p2_screen.y, r2,segment["color"]["rumble"])
	Settings.draw_rectangle(self, p1_screen.x+p1_screen.z+r1, p1_screen.y, r1, p2_screen.x+p2_screen.z+r2, p2_screen.y, r2,segment["color"]["rumble"])

	# The road.
	Settings.draw_rectangle(self, p1_screen.x, p1_screen.y, p1_screen.z, p2_screen.x, p2_screen.y, p2_screen.z, segment["color"]["road"])

	if "lane" in segment["color"]:
		var lane_w1 = p1_screen.z * 2/lanes
		var lane_w2 = p2_screen.z * 2/lanes

		# first lane
		var lane_x1 = p1_screen.x - p1_screen.z + lane_w1
		var lane_x2 = p2_screen.x - p2_screen.z + lane_w2

		# 3 lanes -> 2 markers
		for _i in range(1, lanes):
			Settings.draw_rectangle(self, lane_x1, p1_screen.y, l1, lane_x2, p2_screen.y, l2, segment["color"]["lane"])
			lane_x1 += lane_w1
			lane_x2 += lane_w2


func rumble_width(projected_road_width: float):
	return projected_road_width/max(6, 2*lanes)

func lane_marker_width(projected_road_width: float):
	return projected_road_width/max(32, 8*lanes)
