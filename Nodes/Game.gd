extends Node2D



onready var player = $Player
onready var background = $Background
onready var label = $HUD/Label

export var billboard: Texture


# https://codeincomplete.com/articles/javascript-racer-v1-straight/

var fov = 100
var rumble_length = 3 # number of segments per red/white strip
var fieldOfView   = 100;                    #/ angle (degrees) for field of view
var cameraHeight  = 1000;                   # z height of camera
var cameraDepth   =  1 / tan((fieldOfView/2) * PI/180)                   # z distance camera is from screen (computed)
var drawDistance  = 300;                    #number of segments to draw

var position_z = 1

var max_speed = Settings.SEGMENT_LENGTH * 60
var accel = max_speed/5
var decel = max_speed/5
var braking = max_speed
var speed = 0

var player_position = Vector3(0, 0, cameraHeight*cameraDepth)

var road = Road.new()

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
	road.reset()

	var pz=24385.002543 + 839.099609
	print(road.find_segment(pz).index)


	# Player segment = 125
	# 24336.335872 + 839.099609 = 25175.435481
	# Percent remaining = 0.875
	#  Lerp between p1.y and p2.y: 1445.918945 and  1500 = 1493.239868
	# (0, 1493.239868, 839.099609)
	# Player segment = 125
	# 24385.002543 + 839.099609 = 25224.102153
	# Percent remaining = 0.12
	#  Lerp between p1.y and p2.y: 1445.918945 and  1500 = 1452.408691
	# (0, 1452.408691, 839.099609)
	# Player segment = 126
	# 24433.002548 + 839.099609 = 25272.102158
	# Percent remaining = 0.36
	#  Lerp between p1.y and p2.y: 1500 and  1554.739014 = 1519.706055
	# (0, 1519.706055, 839.099609)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):


	
	var speed_percent = speed/max_speed
	# Z position
	increase_pos(delta)

	var player_segment = road.find_segment(position_z + player_position.z)
	
	# X position
	var dx = delta * 2 * (speed/max_speed)
	if Input.is_action_pressed("steer_left"):
		player_position.x -= dx
	elif Input.is_action_pressed("steer_right"):
		player_position.x += dx
	player_position.x = player_position.x - (dx * speed_percent * player_segment.curve * Settings.CENTRIFUGAL_FORCE)
	player_position.x = clamp(player_position.x, -2, 2)

	label.text = String(player_position)

	# Update the speed
	if Input.is_action_pressed("accelerate"):
		speed += accel *  delta
	elif Input.is_action_pressed("brake"):
		speed -= braking * delta
	else:
		speed -= decel * delta
	speed = clamp(speed, 0, max_speed)
	
	player.camera_scale = cameraDepth / player_position.z

	var player_percent = percent_remaining(position_z+player_position.z, Settings.SEGMENT_LENGTH);
	player_position.y  = lerp(player_segment.p1.world.y, player_segment.p2.world.y, player_percent);

	label.text += "\nPlayer segment = " + String(player_segment.index)
	label.text += "\n" + String(position_z) + " + " + String(player_position.z) + " = " + String(position_z+player_position.z)
	label.text += "\nPercent remaining = " + String(player_percent)
	label.text += "\n Lerp between p1.y and p2.y: " + String(player_segment.p1.world.y) + " and  " + String(player_segment.p2.world.y) + " = " + String(player_position.y)

	#print(label.text)
	# 
	background.adjust_offsets(speed_percent, player_segment.curve)
	# Draw screen
	update()

func increase_pos(delta):
	var res = position_z + delta * speed
	
	while res >= road.track_length:
		res -=  road.track_length

	while res < 0:
		res +=  road.track_length

	position_z = res


func _draw():


	#draw_texture_rect_region(billboard, Rect2(0, 100, 215, 220), Rect2(0, 0, 215, 220))

	var base_segment = road.find_segment(position_z)
	var base_percent = percent_remaining(position_z, Settings.SEGMENT_LENGTH)

	var x = 0
	var dx = - (base_segment.curve*base_percent)

	var maxy = Settings.HEIGHT
	var camera_pos = Vector3((player_position.x * Settings.ROAD_WIDTH), cameraHeight, position_z)
	for n in range(drawDistance):
		
		var segment = road.segments[(base_segment.index+n) % road.segments.size()]
		
		segment.project(camera_pos+Vector3(0, player_position.y, 0), cameraDepth, x, dx)
		segment.clip = null # maxy
		#project(segment.p1, camera_pos)
		#project(segment.p2, camera_pos)

		x = x + dx
		dx = dx + segment.curve
		
		# CLIP
		# behind us or backface cull OR clip by (already rendered) segment
		if (segment.p1.camera.z <= cameraDepth) or  (segment.p2.screen.y >= segment.p1.screen.y) or	(segment.p2.screen.y >= maxy):
			  segment.clip = maxy
			  continue;
		
		maxy = segment.p2.screen.y;
		# Render the segment
		segment.draw(self)

	# Render sprites back to front.
	for n in range(drawDistance-1, 0, -1):
		var segment = road.segments[(base_segment.index+n) % road.segments.size()]

		for sprite in segment.sprites:
			var sprite_scale = segment.p1.screen_scale

			# width = sprite_width * scale * screen
			var w = 700 * sprite_scale * Settings.WIDTH/2
			var h = 1000 * sprite_scale * Settings.WIDTH/2
			
			#var clip_h = max(0, segment.p1.screen.y+h-segment.clip)

			# var sprite_top_y = segment.p1.screen.y+h
			# print(h-(segment.clip-segment.p1.screen.y))

			var dest_x = segment.p1.screen.x
			var dest_y = segment.p1.screen.y + h

			# TODO RENDER OVER HILLS
			if segment.clip == null:			
				#Settings.draw_rectangle(self, segment.p1.screen.x, segment.p1.screen.y, w, segment.p2.screen.x, segment.p1.screen.y+h, w, Color.black)
				draw_texture_rect_region(billboard, Rect2(dest_x, dest_y, w, h), Rect2(0, 0, 215, 220))


func percent_remaining(n, total: int):
	#return segments[int(floor(z/Settings.SEGMENT_LENGTH))%segments.size()]
	return float(int(round(n))%total)/float(total)
