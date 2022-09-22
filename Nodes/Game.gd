extends Node2D



onready var player = $Player
onready var background = $Background
onready var texture_manager = $TextureManager
onready var hud = $"%HUD"
onready var road = $"%Road"
onready var checkpoint_timer = $CheckpointTimer
onready var engine: AudioStreamPlayer = $CarEngine
onready var drift_sound: AudioStreamPlayer = $DriftSound
onready var three_sfx = $three
onready var two_sfx = $two
onready var one_sfx = $one
onready var go_sfx = $go
onready var crt = $"%CRT"


var game_over = false

var sec_until_start = 3
var has_started = false

export var billboard: Texture
var current_checkpoint_remaining = 40

# https://codeincomplete.com/articles/javascript-racer-v1-straight/

var fov = 100
var rumble_length = 3 # number of segments per red/white strip
var fieldOfView   = 100;                    #/ angle (degrees) for field of view
var cameraHeight  = 1000;                   # z height of camera
var cameraDepth   =  1 / tan((fieldOfView/2) * PI/180)                   # z distance camera is from screen (computed)
var drawDistance  = 300;                    #number of segments to draw

var position_z = 1

var max_speed = Settings.SEGMENT_LENGTH * 60
var boost_quantity = 1.5
var max_boost_speed = max_speed*boost_quantity
var can_boost = true

var accel = max_speed/5
var decel = max_speed/5
var braking = max_speed
var speed = 0
var offroad_speed = max_speed/4
var offroad_decel = max_speed/2

var drifting = false
var player_position = Vector3(0, 0, cameraHeight*cameraDepth)

var latest_delta = 0

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

var player_dir = Vector2.ZERO
var current_score = Score.new()
var boost_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Settings.retro_effect:
		crt.hide()

	ScoreManager.load_from_file()
	MusicManager.play_level()
	road.connect("circuit_over", self, "_on_circuit_over")
	road.connect("checkpoint_over", self, "_on_checkpoint_over")
	road.reset(player_position.z)
	texture_manager.load_level1()
	current_checkpoint_remaining = road.get_checkpoint_timeout()
	

	yield(get_tree().create_timer(1.0), "timeout")
	hud.show_init()
	hud.update_timer(sec_until_start)
	three_sfx.play()
	$StartTimer.start(1)
	engine.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	latest_delta = delta
	boost_time -= delta

	var player_segment = road.find_segment(position_z + player_position.z)
	var speed_percent = speed/max_speed
	# Z position
	increase_pos(delta)
	var new_player_segment = road.find_segment(position_z + player_position.z)

	if player_segment.index != new_player_segment.index:
		road.on_new_segment(new_player_segment.index, hud.total_time)
	
	# X position
	if has_started:
		var dx = delta * 2 * (speed/max_speed)

		drifting = Input.is_action_pressed("drift")


		if Input.is_action_pressed("steer_left"):
			player_position.x -= dx
			player_dir.x = -1
		elif Input.is_action_pressed("steer_right"):
			player_position.x += dx
			player_dir.x += 1
		else:
			player_dir.x = 0

		var curve_force = (dx * speed_percent * player_segment.curve * Settings.CENTRIFUGAL_FORCE)
		if drifting and player_dir.x != 0:
			curve_force /= 2
		player_position.x = player_position.x - curve_force


		# Update the speed
		if Input.is_action_pressed("accelerate") and speed < max_speed:
			speed += accel *  delta
		elif Input.is_action_pressed("brake"):
			speed -= braking * delta
		else:
			speed -= decel * delta

		if player_position.x < -1 or player_position.x > 1:
			if speed > offroad_speed:
				speed -= offroad_decel * delta
	else:
		speed -= braking * delta

	# Collisions
	# ------------------
	for sprite in player_segment.sprites:
		var sprite_obj = texture_manager.get_texture(sprite["sprite"])
		var sprite_w = sprite_obj.get_collision_width() * texture_manager.sprite_scale
		var sprite_x = sprite["offset"]

		if overlap(player_position.x, texture_manager.player_w, sprite_x, sprite_w, 1):

			# COLLISION
			if sprite_obj.should_collide():
				speed = max_speed/5
				position_z = increase(position_z, -player_position.z, road.track_length)

	# BOOSTERS
	detect_boosters(player_segment)

	# with cars
	for car_idx in new_player_segment.cars:
		var car = road.cars[car_idx]
		var car_w = texture_manager.get_texture(car.sprite_name).get_width() * texture_manager.sprite_scale

		if speed > car.speed:

			if overlap(player_position.x, texture_manager.player_w, car.offset, car_w, 0.8):


				speed = car.speed * (car.speed/speed)
				position_z = increase(position_z, -player_position.z, road.track_length)

	# ------------------

	player_position.x = clamp(player_position.x, player_segment.clamp_x.x, player_segment.clamp_x.y)



	speed = clamp(speed, 0, max_boost_speed)
	
	if speed > max_speed and boost_time <= 0: 
		speed = lerp(speed, max_speed, 0.8*delta)

	player.camera_scale = cameraDepth / player_position.z

	update_cars(delta, player_segment)
	# 
	background.adjust_offsets(speed_percent, player_segment.curve)
	hud.update_speed(speed/max_speed)
	set_engine_pitch()
	# Draw screen
	update()

# dont wanna miss them
func detect_boosters(player_segment):

	var previous_segment = road.segments[player_segment.index - 1]
	var next_segment = road.segments[player_segment.index + 1]


	for segment in [previous_segment, player_segment, next_segment]:
		for sprite in segment.sprites:
			var sprite_obj = texture_manager.get_texture(sprite["sprite"])
			var sprite_w = sprite_obj.get_width() * texture_manager.sprite_scale
			var sprite_x = sprite["offset"]

			if overlap(player_position.x, texture_manager.player_w, sprite_x, sprite_w, 1.0):
				if sprite_obj.should_boost() and boost_time <= 0:
					boost_time = 1
					speed *= boost_quantity
					

# Update position and segments of cars
func update_cars(delta, player_segment):
	for car in road.cars:
		var segment = road.find_segment(car.z)
		car.z = increase(car.z, delta*car.speed, road.track_length)
		var new_segment = road.find_segment(car.z)
		car.percent = percent_remaining(car.z, Settings.SEGMENT_LENGTH)
		car.offset += update_car_offsets(car, segment, player_segment)
		if segment != new_segment:
			segment.remove_car(car.index)
			new_segment.add_car(car.index)

func update_car_offsets(car, segment, player_segment):
	var lookahead = 20 # segments
	var dir = 0
	var car_width = texture_manager.get_texture(car.sprite_name).get_width() * texture_manager.sprite_scale
	for i in range(lookahead):
		var other_segment = road.segments[(segment.index+(i+1)) % road.segments.size()]

		# AVOID PLAYER
		# ----------------------------------
		if segment == player_segment and car.speed > speed and overlap( car.offset, car_width, player_position.x, texture_manager.player_w, 1.2):
			if player_position.x > 0.5:
				dir = -1
			elif player_position.x < -0.5:
				dir = 1
			else:
				if car.offset > player_position.x:
					dir = 1
				else: 
					dir = -1
			var offset = float(dir) * 1/(i+1) * (car.speed - speed)/max_speed
			return offset

		# Replace with function body.
		# AVOID OTHER CARS
		# --------------------------------------
		for car_idx in other_segment.cars:
			var other_car = road.cars[car_idx]
			var other_car_width = texture_manager.get_texture(other_car.sprite_name).get_width() * texture_manager.sprite_scale
			if car.speed > other_car.speed and overlap( car.offset, car_width, other_car.offset, other_car_width, 1.2):
				# Will collide if do nothing. Should steer out of the way.
				if other_car.offset > 0.5:
					dir = -1
				elif other_car.offset < -0.5:
					dir = 1
				else:
					if car.offset > other_car.offset:
						dir = 1
					else: 
						dir = -1
				var offset = float(dir) * 1/(i+1) * (car.speed - other_car.speed)/max_speed
				return offset
	
	return 0


func increase_pos(delta):
	var res = position_z + delta * speed
	
	while res >= road.track_length:
		res -=  road.track_length

	while res < 0:
		res +=  road.track_length

	position_z = res

func increase(start, increment, maximum):
	var res = start + increment
	
	while res >= maximum:
		res -=  maximum

	while res < 0:
		res +=  maximum

	return res


func _draw():

	var base_segment = road.find_segment(position_z)
	var base_percent = percent_remaining(position_z, Settings.SEGMENT_LENGTH)
	var player_segment = road.find_segment(position_z + player_position.z)
	var player_percent = percent_remaining(position_z+player_position.z, Settings.SEGMENT_LENGTH);
	player_position.y  = lerp(player_segment.p1.world.y, player_segment.p2.world.y, player_percent);
	var x = 0
	var dx = - (base_segment.curve*base_percent)

	var maxy = Settings.HEIGHT
	var camera_pos = Vector3((player_position.x * Settings.ROAD_WIDTH), cameraHeight, position_z)

	var min_draw_distance = min(drawDistance, road.segments.size()) 
	for n in range(min_draw_distance):
		
		var segment = road.segments[(base_segment.index+n) % road.segments.size()]
		
		segment.looped = segment.index < base_segment.index
		segment.project(camera_pos+Vector3(0, player_position.y, 0), cameraDepth, x, dx, road.track_length)
		segment.clip = null
		x = x + dx
		dx = dx + segment.curve
		
		# CLIP
		# behind us or backface cull OR clip by (already rendered) segment
		if (segment.p1.camera.z <= cameraDepth) or  (segment.p2.screen.y >= segment.p1.screen.y) or	(segment.p2.screen.y >= maxy):
			segment.clip = maxy
			continue;
		
		maxy = segment.p2.screen.y;
		
		# Render the segment
		segment.draw(self, texture_manager)

	background.set_sea_level(maxy)

	# Render sprites back to front.
	for n in range(min_draw_distance-1, 0, -1):
		var segment = road.segments[(base_segment.index+n) % road.segments.size()]
		var scale = segment.p1.screen_scale
		
		for sprite in segment.sprites:
			texture_manager.get_texture(sprite["sprite"]).update(latest_delta)
			var sprite_x = segment.p1.screen.x + sprite["offset"] * scale * Settings.ROAD_WIDTH * Settings.WIDTH/2
			draw_sprite(sprite["sprite"], Vector2(sprite_x, segment.p1.screen.y), segment.p1.screen_scale, segment.clip, sprite["sprite_coords"])

		for car_idx in segment.cars:
			var car = road.cars[car_idx]

			var car_scale = lerp(segment.p1.screen_scale, segment.p2.screen_scale, car.percent)
			var car_x = lerp(segment.p1.screen.x, segment.p2.screen.x, car.percent) + car.offset * car_scale * Settings.ROAD_WIDTH * Settings.WIDTH/2
			var car_y = lerp(segment.p1.screen.y, segment.p2.screen.y, car.percent);
			
			draw_sprite(car.sprite_name, Vector2(car_x, car_y), car_scale, segment.clip, Vector2(car.sprite_coords_x,0))

	draw_player(player_segment)

func draw_sprite(name: String, pos: Vector2, scale: float, clip, sprite_coords):
	var my_sprite: MySprite = texture_manager.get_texture(name)
	if my_sprite == null:
		return
	my_sprite.draw_sprite(self, texture_manager,  pos, scale, clip, sprite_coords)

func draw_player(segment):

	var going_up = segment.p2.world.y > segment.p1.world.y

	var bounce = (1.5 * randf() * speed/max_speed * Settings.HEIGHT/480) * float (randi() % 2 - 1)
	var sprite_coords = Vector2.ZERO
	if has_started:
		if not going_up:
			if player_dir.x < 0:

				if drifting:
					sprite_coords.x = Settings.PLAYER_COORD.DRIFT_LEFT
				else:
					sprite_coords.x = Settings.PLAYER_COORD.STRAIGHT_LEFT
			elif player_dir.x > 0:
				if drifting:

					sprite_coords.x = Settings.PLAYER_COORD.DRIFT_RIGHT
				else:
					sprite_coords.x = Settings.PLAYER_COORD.STRAIGHT_RIGHT
			else:
				sprite_coords.x = Settings.PLAYER_COORD.STRAIGHT
		else:
			if player_dir.x < 0:
				if drifting:
					sprite_coords.x = Settings.PLAYER_COORD.DRIFT_LEFT
				else:
					sprite_coords.x = Settings.PLAYER_COORD.UP_LEFT
			elif player_dir.x > 0:
				if drifting:
					sprite_coords.x = Settings.PLAYER_COORD.DRIFT_RIGHT
				else:
					sprite_coords.x = Settings.PLAYER_COORD.UP_RIGHT
			else:
				sprite_coords.x = Settings.PLAYER_COORD.UP
	else:
		sprite_coords.x = Settings.PLAYER_COORD.STRAIGHT

	draw_sprite("player", Vector2(Settings.WIDTH/2, Settings.HEIGHT+ bounce), cameraDepth/player_position.z, null, sprite_coords)
	draw_sprite("player_lights", Vector2(Settings.WIDTH/2, Settings.HEIGHT+ bounce), cameraDepth/player_position.z, null, sprite_coords)

func percent_remaining(n, total: int):
	#return segments[int(floor(z/Settings.SEGMENT_LENGTH))%segments.size()]
	return float(int(round(n))%total)/float(total)

func overlap(x1, w1, x2, w2, percent):
	var half = float(percent)/float(2.0)
	var min1 = x1-w1*half
	var max1 = x1+w1*half
	var min2 = x2-w2*half
	var max2 = x2+w2*half

	return not ((max1 < min2) or (min1 > max2))


func _on_StartTimer_timeout():
	sec_until_start -= 1

	match sec_until_start:
		2: two_sfx.play()
		1: one_sfx.play()
		0: go_sfx.play()

	hud.update_timer(sec_until_start)
	if sec_until_start == 0:
		has_started = true
		hud.start()
		hud.new_lap()
		current_checkpoint_remaining = road.get_checkpoint_timeout()
		hud.update_checkpoint(current_checkpoint_remaining)
		$StartTimer.stop()
		checkpoint_timer.start(1)

func _on_circuit_over():
	if not game_over:
		checkpoint_timer.stop()
		has_started = false
		checkpoint_timer.stop()

		var TW = get_tree().create_tween()
		TW.tween_property(engine, "volume_db", -60.0, .5)
		TW.tween_interval(1.5)
		#TW.tween_callback(engine, "set_playing", [false])
		TW.tween_property(engine, "playing", false, 0)
		
		var score = Score.new()
		score.checkpoints = []
		score.total_time = hud.total_time
		for i in range(road.checkpoints.size()):
			if "completed_in" in road.checkpoints[i]:
				score.checkpoints.append(road.checkpoints[i]["completed_in"])
				print("Checkpoint " + String(i) + " completed in " + String(road.checkpoints[i]["completed_in"]))
		ScoreManager.save_new_score(score)

		hud.finished()

func _on_checkpoint_over(previous_index, time_to_checkpoint):
	# display difference of time
	current_checkpoint_remaining = road.get_checkpoint_timeout()
	
	hud.new_checkpoint(ScoreManager.get_checkpoint_diff(previous_index, time_to_checkpoint))
	hud.update_checkpoint(current_checkpoint_remaining)

func _on_CheckpointTimer_timeout():
	current_checkpoint_remaining -= 1

	if current_checkpoint_remaining == 0:
		hud.game_over()
		game_over = true
		has_started = false

	hud.update_checkpoint(current_checkpoint_remaining)


func set_engine_pitch():
	var pitch = 1.0 + speed/max_speed
	engine.pitch_scale = pitch

	if drifting and player_dir.x != 0 and has_started:
		if not drift_sound.playing:
			drift_sound.play()
	else:
		drift_sound.stop()
		
		

func _on_PauseScene_exit_to_menu():
	hud.hide()
	Transition.change_scene("res://Screens/screen_main.tscn")

func _on_WinScreen_go_back():
	hud.hide()
	Transition.change_scene("res://Screens/screen_main.tscn")



func _on_GameOverScreen_go_back():
	hud.hide()
	Transition.change_scene("res://Screens/screen_main.tscn")
