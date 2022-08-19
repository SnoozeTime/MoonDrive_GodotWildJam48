class_name MySprite extends Reference

var texture: Texture = null
var sprite_dimensions = Vector2.ZERO # texture offset
var modulate = Color(1, 1, 1, 1)
var collision = true
var boost = false
var projected = false

var animated = false
var animated_coord = 0

var time_per_frame = 0.5 # seconds
var current_frame = 0

var rows_cols = Vector2.ONE

var collider_width = 1

func _init(t: Texture, rows: int, cols: int):
	texture = t
	rows_cols.x = rows
	rows_cols.y = cols
	sprite_dimensions = Vector2(texture.get_width()/cols, texture.get_height()/rows)
	collider_width = sprite_dimensions.x

func draw_sprite(node2d: Node2D, texture_manager, pos: Vector2, scale: float, clip, sprite_coords = Vector2.ZERO):
	var dest_dim = scale * Settings.WIDTH/2 * (Settings.ROAD_WIDTH * texture_manager.sprite_scale) * sprite_dimensions
	var dest_x = pos.x - dest_dim.x/2
	var dest_y = pos.y - dest_dim.y

	var clip_h = 0
	if clip != null:
		clip_h = max(0, clip- dest_y)
		if dest_y > clip:
			return
	#if clip == null:
	if animated:
		sprite_coords.x = animated_coord

	var sprite_h = sprite_dimensions.y
	var dest_h = dest_dim.y
	if clip_h > 0:
		sprite_h = sprite_dimensions.y * clip_h / dest_dim.y
		dest_h = clip_h
	
	node2d.draw_texture_rect_region(texture, Rect2(dest_x, dest_y, dest_dim.x, dest_h), Rect2(sprite_coords.x * sprite_dimensions.x, 0, sprite_dimensions.x, sprite_h), modulate)

func update(delta):
	if animated:
		current_frame+=delta
		if current_frame >= time_per_frame:
			current_frame -= time_per_frame
			animated_coord = (animated_coord+1) % int(rows_cols.y)


func get_width() -> float:
	return sprite_dimensions.x

func get_collision_width() -> float:
	return collider_width

func should_collide() -> bool:
	return collision

func should_boost() -> bool:
	return boost
