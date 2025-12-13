## Places and retrieves controls in a resizable grid space.
## Coordinate metadata is stored on any placed control as meta key "coord": Vector2i
class_name GameGrid
extends Container

## Number of items to fit horizontally. Value of 0 will tile infinitely
@export var horizontal_items: int = 0
## Number of items to fit vertically. Value of 0 will tile infinitely
@export var vertical_items: int = 0

# (x,y,layer) -> Control
var _map: Dictionary[Vector3i, Control] = {}

func _ready() -> void:
	_rebuild_map()
	queue_sort()

## Places `control` at `coord`.
## Returns false if coord is outside range (when an axis is non-zero), or if the cell is occupied by a different control.
func place_control(control: Control, coord: Vector2i, layer: int = 0) -> bool:
	if control is TextureRect:
		(control as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var key = coord_layer_to_vector3i(coord, layer)
	if not _coord_in_range(coord):
		return false

	if _map.has(key):
		var existing: Control = _map[key]
		if is_instance_valid(existing) and existing != control:
			return false

	# Remove old mapping for this control if it already had a coord
	#if control.has_meta("coord"):
		#var old_coord: Vector2i = control.get_meta("coord") as Vector2i
		#if _map.get(old_coord) == control:
			#_map.erase(old_coord)

	if control.get_parent() != self:
		if control.get_parent() != null:
			control.get_parent().remove_child(control)
		add_child(control)

	control.set_meta("coord", coord)
	_map[key] = control
	queue_sort()
	return true


## Gets the control at `coord`
func get_control(coord: Vector2i, layer: int = 0) -> Control:
	var key = coord_layer_to_vector3i(coord, layer)
	if _map.has(key):
		var c: Control = _map[key]
		if is_instance_valid(c):
			return c
		_map.erase(coord)

	#for child in get_children():
		#if child is Control and child.has_meta("coord") and (child.get_meta("coord") as Vector2i) == coord:
			#_map[coord] = child
			#return child

	return null


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN or what == NOTIFICATION_RESIZED:
		_sort_into_grid()
	elif what == NOTIFICATION_CHILD_ORDER_CHANGED:
		_rebuild_map()
		queue_sort()


func _sort_into_grid() -> void:
	var cell := _cell_size()

	for child in get_children():
		if child is not Control:
			continue

		var coord := Vector2i.ZERO
		if child.has_meta("coord"):
			coord = child.get_meta("coord") as Vector2i

		var rect := Rect2(Vector2(coord.x * cell.x, coord.y * cell.y), cell)
		fit_child_in_rect(child, rect)


func _cell_size() -> Vector2:
	# Rule: each cell is 1/N of this GameGrid's size when N > 1.
	# 0 or 1 means "one cell fills the whole axis".
	var cols := _divisor(horizontal_items)
	var rows := _divisor(vertical_items)
	return Vector2(size.x / float(cols), size.y / float(rows))

func _divisor(n: int) -> int:
	return 1 if n <= 1 else n


func _coord_in_range(coord: Vector2i) -> bool:
	# Any axis set to 0 tiles infinitely on that axis (no bounds check).
	if horizontal_items > 0:
		if coord.x < 0 or coord.x >= horizontal_items:
			return false
	if vertical_items > 0:
		if coord.y < 0 or coord.y >= vertical_items:
			return false
	return true


func _rebuild_map() -> void:
	_map.clear()
	for child in get_children():
		if child is Control and child.has_meta("coord"):
			var child_coord: Vector2i = child.get_meta("coord")
			_map[coord_layer_to_vector3i(child_coord, (child as Control).z_index)] = child

func coord_layer_to_vector3i(coord: Vector2i, layer: int) -> Vector3i:
	return Vector3i(coord.x, coord.y, layer)
	 
