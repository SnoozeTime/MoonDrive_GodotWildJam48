extends Node


var debug = true

# length of single segment
const SEGMENT_LENGTH = 200
 # number of segments per red/white strip
const RUMBLE_LENGTH = 3

const WIDTH = 1024
const HEIGHT = 768
const LANES = 3
const ROAD_WIDTH = 2000 

var retro_effect = true

# When turning
const CENTRIFUGAL_FORCE = 0.3

const COLORS_LIGHT = {
	"road": Color("#261a5a"),
	"grass": Color("#1f684a"),
	"rumble": Color("#bb3ad3"),
	"lane": Color('#CCCCCC'),
	"water": Color.blue,
}

const COLORS_DARK = {
	"road": Color("#1a1044"),
	"grass": Color("#114530"),
	"rumble": Color("#bb3ad3"),
	"water": Color.blue,
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


enum PLAYER_COORD {
	STRAIGHT = 0,
	STRAIGHT_LEFT = 1,
	DRIFT_RIGHT,
	STRAIGHT_RIGHT,
	UP,
	UP_LEFT,
	UP_RIGHT,
	DRIFT_LEFT
}

func rumble_width(projected_road_width: float):
	return projected_road_width/max(6, 3*LANES)

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

func draw_textured_rectangle(node_2d: Node2D, x1, y1, w1, x2, y2, w2, texture):	
	var p1_left = Vector2(x1 - w1, y1)
	var p1_right = Vector2(x1 + w1, y1)
	var p2_left = Vector2(x2-w2, y2)
	var p2_right = Vector2(x2+w2, y2)
	var array = PoolVector2Array()
	
	array.push_back(p1_left)
	array.push_back(p1_right)
	array.push_back(p2_right)
	array.push_back(p2_left)

	var colors = PoolColorArray()
	colors.append(Color.white)
	colors.append(Color.white)
	colors.append(Color.white)
	colors.append(Color.white)

	var uvs = PoolVector2Array()
	uvs.append(Vector2(0,0))
	uvs.append(Vector2(1,0))
	uvs.append(Vector2(1,1))
	uvs.append(Vector2(0,1))
	if not Geometry.triangulate_polygon(array).empty():
		node_2d.draw_polygon (array, colors, uvs, texture)
