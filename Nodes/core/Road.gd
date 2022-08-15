class_name Road


var segments = []
var track_length = 0


func reset():
	segments = []
	add_straight_road(Settings.ROAD_LENGTH.SHORT)
	add_low_rolling_hills(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_HILL.HIGH)
	add_s_curves()
	add_low_rolling_hills(Settings.ROAD_LENGTH.SHORT, Settings.ROAD_HILL.HIGH)
	add_s_curves()

	segments[20].add_sprite(null, 20)
	segments[100].add_sprite(null, 20)
	segments[200].add_sprite(null, 20)
	segments[250].add_sprite(null, 20)
	segments[350].add_sprite(null, 20)

	track_length = segments.size()*Settings.SEGMENT_LENGTH

func add_segment(curve, y):
	var n = segments.size()
	segments.append(Segment.new(last_segment_y(), y, n, curve))

func add_s_curves():
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.EASY)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.MEDIUM)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_CURVE.EASY)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.EASY)
	add_road(Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, Settings.ROAD_LENGTH.MEDIUM, -Settings.ROAD_CURVE.MEDIUM)

func add_low_rolling_hills(num, height):
	add_road(num, num, num, 0, height/2)
	add_road(num, num, num, 0, -height)
	add_road(num, num, num, 0, height)
	add_road(num, num, num, 0, 0)
	add_road(num, num, num, 0, 0)

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
