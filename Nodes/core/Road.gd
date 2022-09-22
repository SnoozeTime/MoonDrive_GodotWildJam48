class_name Road extends Node

signal checkpoint_over
signal circuit_over

var total_cars = 150
var segments = []
var track_length = 0
var cars = []
var current_checkpoint = 0

var checkpoints = []
var start_index = 0
var end_index = 0

var last_checkpoint_time = 20
func reset(player_pos: float):
	segments = []

	# HILL TO THE MOON
	add_straight_road(Settings.ROAD_LENGTH.SHORT)
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.MEDIUM, 0, 0, Settings.ROAD_HILL.HIGH)
	add_road(0, Settings.ROAD_LENGTH.MEDIUM, 0, 0, Settings.ROAD_HILL.HIGH)
	add_road(0, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.SHORT, 0, Settings.ROAD_HILL.HIGH)
	add_straight_road(Settings.ROAD_LENGTH.LONG)
	
	#
	add_large_turn(1)
	add_large_turn(1)
	checkpoints.append({"time": 30, "index": segments.size()-1, "end": false})
	# Rolling hills

	add_medium_rolling_hills(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_HILL.HIGH)
	
	var bridge1_start = segments.size()-1 
	add_medium_rolling_hills(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_HILL.HIGH)
	for i in range(bridge1_start, segments.size()):
		if i % 10 == 0:
			segments[i].add_sprite("bridge", 0)
	#
	add_large_turn(-1)


	var city_start = segments.size()
	add_large_turn(-1)


	# CITY TIME
	# Add boosts and shit
	# ---------------------
	
	checkpoints.append({"time": 40, "index": segments.size()-1, "end": false})
	add_straight_road(Settings.ROAD_LENGTH.LONG)
	add_medium_rolling_hills(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_HILL.HIGH)
	add_straight_road(Settings.ROAD_LENGTH.LONG)
	add_large_turn(1)
	add_straight_road(Settings.ROAD_LENGTH.LONG)

	for i in range(city_start, segments.size()):
		segments[i].left_side = Segment.SIDE_TYPE.City
		segments[i].right_side = Segment.SIDE_TYPE.City

		if i % 5 == 0:
			
			segments[i].add_sprite("building2", rand_range(-1.5, -6), Vector2(1, 0))
			segments[i].add_sprite("building2", rand_range(-1.5, -6))
			segments[i].add_sprite("building2", rand_range(1.5, 6), Vector2(2, 0))
			segments[i].add_sprite("building2", rand_range(1.5, 6), Vector2(3, 0))

		if i % 100 == 0:
			segments[i].add_sprite("boost", rand_range(-0.5, 0.5))

	# CITY END

	checkpoints.append({"time": 35, "index": segments.size()-1, "end": false})
	add_climbing_curves(Settings.ROAD_HILL.LOW)
	add_large_turn(-1)
	add_large_turn(1)
	add_climbing_curves(Settings.ROAD_HILL.HIGH)

	# BEACH and see
	#= ==========================================
	var beach_start = segments.size()
	checkpoints.append({"time": 40, "index": segments.size()-1, "end": false})
	# 20s to reach that checkpoint
	add_low_rolling_hills(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_HILL.HIGH)
	#add_s_curves()

	add_straight_road(Settings.ROAD_LENGTH.LONG)
	
	checkpoints.append({"time": 25, "index": segments.size()-1, "end": false})
	add_straight_road(Settings.ROAD_LENGTH.LONG)

	# TURN
	add_large_turn(-1)
	add_large_turn(-1)

	for i in range(beach_start, segments.size()):
		segments[i].right_side = Segment.SIDE_TYPE.Beach
		if i % 15 == 0:
			segments[i].add_sprite("palmtree", -1.3)
			segments[i].add_sprite("palmtree", 1.3)
			
		
		if i % 100 == 0:
			segments[i].add_sprite("boost", rand_range(-0.5, 0.5))
	# ============================================

	# BRIDGE
	
	checkpoints.append({"time": 30, "index": segments.size()-1, "end": false})
	var bridge_start = segments.size()
	add_straight_road(Settings.ROAD_LENGTH.LONG)
	add_straight_road(Settings.ROAD_LENGTH.LONG)
	for i in range(bridge_start, segments.size()):
		
		if i % 10 == 0:
			segments[i].add_sprite("fence_left", -1.3)
			segments[i].add_sprite("fence_left", 1.3, Vector2(1, 0))

		if i % 100 == 0:
			segments[i].add_sprite("boost", rand_range(-0.5, 0.5))
		segments[i].right_side = Segment.SIDE_TYPE.None
		segments[i].left_side = Segment.SIDE_TYPE.None
		segments[i].clamp_x = Vector2(-1, 1)

	# 40s to reach that checkpoint
	checkpoints.append({"time": 35, "index": segments.size()-1, "end": false})
	#add_low_rolling_hills(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_HILL.HIGH)
	add_s_curves2()
	# 50s to reach that checkpoint
	add_more_roads()

	checkpoints.append({"time": 30, "index": segments.size()-1, "end": true})
	

	# Just to have a nice road at the end.
	add_straight_road(Settings.ROAD_LENGTH.MEDIUM)

	reset_cars()

	track_length = segments.size()*Settings.SEGMENT_LENGTH

	start_index = segment_index(player_pos)

	segments[start_index].floor_indication = Color.white
	for c in checkpoints:
		segments[c["index"]].floor_indication = Color.aliceblue
		segments[c["index"]].add_sprite("checkpoint", 0)

		
	for i in segments.size():
		if segments[i].left_side == Segment.SIDE_TYPE.None:
			continue
		
		if i % 5 == 0:

			if randf() > 0.7:
				
				var offset = sign(rand_range(-1, 1))*rand_range(1.5, 4)
				if offset != 0:
				
					segments[i].add_sprite("bush", offset)

		
			if randf() > 0.7:
				var offset = sign(rand_range(-1, 1))*rand_range(1.5, 4)
				if offset != 0:
				
					segments[i].add_sprite("bush", offset)
				
			if randf() > 0.7:
				var offset = sign(rand_range(-1, 1))*rand_range(1.5, 4)
				if offset != 0:
				
					segments[i].add_sprite("bush", offset)
					
		if i % 15 == 0:

			if randf() > 0.7:
				
				var offset = sign(rand_range(-1, 1))*rand_range(1.5, 4)
				if offset != 0:
				
					segments[i].add_sprite("palmtree", offset)

		
			if randf() > 0.7:
				var offset = sign(rand_range(-1, 1))*rand_range(1.5, 4)
				if offset != 0:
				
					segments[i].add_sprite("palmtree", offset)
				
			if randf() > 0.7:
				var offset = sign(rand_range(-1, 1))*rand_range(1.5, 4)
				if offset != 0:
				
					segments[i].add_sprite("palmtree", offset)

func add_segment(curve, y):
	var n = segments.size()
	segments.append(Segment.new(last_segment_y(), y, n, curve))

func add_s_curves():
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.EASY)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.MEDIUM)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.EASY)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.EASY)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.MEDIUM)



func add_s_curves2():
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.HARD, Settings.ROAD_HILL.HIGH)
	add_road(0, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.HARD, Settings.ROAD_HILL.HIGH)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.EASY, -Settings.ROAD_HILL.LOW)
	add_road(0, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.EASY, -Settings.ROAD_HILL.LOW)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.MEDIUM, Settings.ROAD_HILL.LOW)

func add_climbing_curves(height):
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.EASY, height)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.MEDIUM, -height/2)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.EASY, -height)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.EASY, 0)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.MEDIUM, height/2)

func add_more_roads():
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, -Settings.ROAD_CURVE.HARD)
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_CURVE.HARD)
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, -Settings.ROAD_CURVE.HARD)
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_CURVE.HARD)

func add_low_rolling_hills(num, height):
	add_road(num, num, num, 0, height/2)
	add_road(num, num, num, 0, -height)
	add_road(num, num, num, 0, height)
	add_road(num, num, num, 0, 0)
	add_road(num, num, num, 0, 0)

func add_medium_rolling_hills(num, height):
	add_road(num, num, num, 0, height)
	add_road(num, num, num, 0, -height*2)
	add_road(num, num, num, 0, height)
	add_road(num, num, num, 0, height/2)
	add_road(num, num, num, 0, -height/2)

func add_climbing_hill():
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, 0, Settings.ROAD_HILL.HIGH)
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, 0, Settings.ROAD_HILL.HIGH)
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, 0, Settings.ROAD_HILL.HIGH)

func add_large_turn(dir):
	add_road(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, 0, dir*Settings.ROAD_CURVE.HARD)
	add_road(0, Settings.ROAD_LENGTH.SHORT, 0, dir*Settings.ROAD_CURVE.HARD)
	add_road(0, Settings.ROAD_LENGTH.SHORT, 0, dir*Settings.ROAD_CURVE.HARD)
	add_road(0, Settings.ROAD_LENGTH.SHORT, Settings.ROAD_LENGTH.SHORT, dir*Settings.ROAD_CURVE.HARD)

func add_straight_road(num):
	add_road(num, num, num)

func add_road(enter, hold, leave, curve := 0, y := 0):
	var start_y = last_segment_y()
	var end_y = start_y + y * Settings.SEGMENT_LENGTH
	var total = float(enter+hold+leave)

	for n in range(enter):
		add_segment(ease_in(0, curve, n/enter), ease_in_out(start_y, end_y, float(n)/total))

	for n in range(hold):
		add_segment(curve, ease_in_out(start_y, end_y, float(n+enter)/total))

	for n in range(leave):
		add_segment(ease_in_out(curve, 0, n/leave), ease_in_out(start_y, end_y, float(n+hold+enter)/total))



func find_segment(z):
	return segments[int(floor(z/Settings.SEGMENT_LENGTH))%segments.size()]

func segment_index(z):
	return int(floor(z/Settings.SEGMENT_LENGTH))%segments.size()

func ease_in(a, b, percent):
	return a + (b-a) * pow(percent, 2)

func ease_out(a, b, percent):
	return a + (b-a) * (1-pow(1-percent, 2))

func ease_in_out(a, b, percent):
	return a + (b-a) * ((-cos(percent*PI)/2) + 0.5)


func last_segment_y():
	if segments.size() == 0:
		return 0
	else:
		return segments[segments.size()-1].p2.world.y

func reset_cars():
	cars = []

	for _i in range(total_cars):
		var car = Car.new()
		car.z = floor(randf() * segments.size()) * Settings.SEGMENT_LENGTH
		car.offset  = rand_range(-0.8, 0.8)
		var max_speed = Settings.SEGMENT_LENGTH * 60
		car.speed = max_speed / 4 + max_speed/rand_range(2, 4)
		car.index = cars.size()

		var segment = find_segment(car.z)
		segment.add_car(car.index)
		cars.append(car) 

func on_new_segment(index: int, total_time: float):

	for checkpoint in checkpoints:
		if checkpoint["index"] == index:
			if checkpoint["end"]:
				emit_signal("circuit_over")
			else:

				checkpoint["completed_in"] = total_time
				print("Completed checkpoint in " + String(checkpoint["completed_in"]))
				current_checkpoint +=1
				emit_signal("checkpoint_over", current_checkpoint-1, total_time)
			break

		

func get_checkpoint_timeout():
	return checkpoints[current_checkpoint]["time"]
