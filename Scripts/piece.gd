## base class for all objects occupying a space on the board
class_name Piece
extends TextureRect

signal on_piece_clicked(piece: Piece)

var coord: Vector2i
var board: Board:
	get:
		return get_parent()

var full_coord: Vector4i:
	get:
		var p = get_parent()
		return Vector4i(p.coord.x,p.coord.y,coord.x,coord.y)
	set(val):
		coord.x = val.z
		coord.y = val.w

func _on_click():
	pass

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed):
		return
	on_piece_clicked.emit(self)
	_on_click()
