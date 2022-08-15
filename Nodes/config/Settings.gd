extends Node

# length of single segment
const SEGMENT_LENGTH = 200
 # number of segments per red/white strip
const RUMBLE_LENGTH = 3

const WIDTH = 1024
const HEIGHT = 768
const LANES = 3
const ROAD_WIDTH = 2000 

# When turning
const CENTRIFUGAL_FORCE = 0.3

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

# FOR CURVES
enum ROAD_LENGTH {
	NONE = 0,
	SHORT = 25,
	MEDIUM = 50,
	LONG = 100
}

enum ROAD_CURVE {
	NONE = 0,
	EASY = 2,
	MEDIUM = 4,
	HARD = 6
}

enum ROAD_HILL {
	NONE = 0,
	LOW = 20,
	MEDIUM = 40,
	HIGH = 60
}

func rumble_width(projected_road_width: float):
	return projected_road_width/max(6, 2*LANES)

func lane_marker_width(projected_road_width: float):
	return projected_road_width/max(32, 8*LANES)



func draw_rectangle(node_2d: Node2D, x1, y1, w1, x2, y2, w2, color):
	var p1_left = Vector2(x1 - w1, y1)
	var p1_right = Vector2(x1 + w1, y1)
	var p2_left = Vector2(x2-w2, y2)
	var p2_right = Vector2(x2+w2, y2)
	var array = PoolVector2Array()
	
	array.push_back(p1_left)
	array.push_back(p1_right)
	array.push_back(p2_right)
	array.push_back(p2_left)
	if not Geometry.triangulate_polygon(array).empty():
		node_2d.draw_colored_polygon (array, color)
