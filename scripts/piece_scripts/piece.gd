# Summary: Base control for board occupants, handling position metadata and click signalling.
## base class for all objects occupying a space on the board
class_name Piece
extends Control

signal on_piece_clicked(piece: Piece)

static var piece_script = preload("res://scripts/piece_scripts/piece.gd")
static var square_scene = preload("res://scenes/pieces/square.tscn")

var is_overlay: bool = false

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

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	push_warning("blocks_movement function not set on piece " + name + ", defaulting to false.")
	return false

func _on_click():
	pass

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed):
		return
	on_piece_clicked.emit(self)
	_on_click()
