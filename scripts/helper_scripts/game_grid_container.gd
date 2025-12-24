## Places and retrieves controls in a resizable grid space.
## Coordinate metadata is stored on any placed control as meta key "coord": Vector2i
class_name GameGrid
extends Container

signal space_selected(position: Vector2i, control: Control)

## Number of items to fit horizontally. Value of 0 will tile infinitely
@export var horizontal_items: int = 0
## Number of items to fit vertically. Value of 0 will tile infinitely
@export var vertical_items: int = 0

var _top_layer = 0

# (x,y,layer) -> Control
var _map: Dictionary[Vector3i, Control] = {}

## Places `control` at `coord`.
## Returns false if coord is outside range (when an axis is non-zero), or if the cell is occupied by a different control.
func place_control(control: Control, coord: Vector2i, layer: int = 0) -> bool:
	if layer > _top_layer: _top_layer = layer
	if control is TextureRect:
		(control as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var key = _coord_layer_to_vector3i(coord, layer)
	if not coord_in_range(coord):
		return false

	if _map.has(key):
		_map[key].queue_free()

	if control.get_parent() != null:
		control.get_parent().remove_child(control)
	control.set_meta("coord", coord)
	control.z_index = layer
	add_child(control)
	_map[key] = control
	queue_sort()
	_rebuild_map()
	return true

## Gets the control at `coord`
## Checks layers from the given layer (or top) down to 0
func get_control(coord: Vector2i, layer: int = -1) -> Control:
	if layer == -1:
		layer = _top_layer

	for l in range(layer, -1, -1):
		var key = _coord_layer_to_vector3i(coord, l)
		if _map.has(key):
			var c: Control = _map[key]
			if _is_valid_node(c):
				return c
			_map.erase(key)
	return null

func all_controls():
	return get_children().filter(_is_valid_node)

func mouse_coord() -> Vector2i:
	var local_pos = get_local_mouse_position()
	var horz = local_pos.x/(size.x/_divisor(horizontal_items))
	var vert = local_pos.y/(size.y/_divisor(vertical_items))
	var local_coord_pos = Vector2i(floor(horz), floor(vert))
	return local_coord_pos

func cell_size() -> Vector2:
	# Rule: each cell is 1/N of this GameGrid's size when N > 1.
	# 0 or 1 means "one cell fills the whole axis".
	var cols := _divisor(horizontal_items)
	var rows := _divisor(vertical_items)
	return Vector2(size.x / float(cols), size.y / float(rows))

func coord_in_range(coord: Vector2i) -> bool:
	# Any axis set to 0 tiles infinitely on that axis (no bounds check).
	if horizontal_items > 0:
		if coord.x < 0 or coord.x >= horizontal_items:
			return false
	if vertical_items > 0:
		if coord.y < 0 or coord.y >= vertical_items:
			return false
	return true

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	_rebuild_map()
	queue_sort()

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN or what == NOTIFICATION_RESIZED:
		_sort_into_grid()
	elif what == NOTIFICATION_CHILD_ORDER_CHANGED:
		_rebuild_map()
		queue_sort()


func _sort_into_grid() -> void:
	var cell := cell_size()

	for child in get_children():
		if child is not Control:
			continue

		var coord := Vector2i.ZERO
		if child.has_meta("coord"):
			coord = child.get_meta("coord") as Vector2i
		var rect := Rect2(Vector2(coord.x * cell.x, coord.y * cell.y), cell)
		fit_child_in_rect(child, rect)

func _divisor(n: int) -> int:
	return 1 if n <= 1 else n

func _rebuild_map() -> void:
	_map.clear()
	for child in get_children():
		if child is Control and child.has_meta("coord"):
			var child_coord: Vector2i = child.get_meta("coord")
			_map[_coord_layer_to_vector3i(child_coord, (child as Control).z_index)] = child

func _coord_layer_to_vector3i(coord: Vector2i, layer: int) -> Vector3i:
	return Vector3i(coord.x, coord.y, layer)

func _is_valid_node(node: Node) -> bool:
	if not is_instance_valid(node):
		return false
	if node.is_queued_for_deletion():
		return false
	return true

func flip_y(coord: Vector2i) -> Vector2i:
	return Vector2i(coord.x, _divisor(vertical_items) - coord.y -1)

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed):
		return
	var coord = mouse_coord()
	#var controls = all_controls()
	#var filtered_controls = controls.filter(func(cont): (cont as Node).get_meta("coord") == coord)
	#filtered_controls.sort_custom(func(a, b):return a.z_index < b.z_index)
	space_selected.emit(coord, get_control(coord))
