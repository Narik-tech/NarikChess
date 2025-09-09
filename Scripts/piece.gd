class_name ChessPiece
extends TextureRect

signal piece_selected(coord: Vector4i)

var coord: Vector2i
var piece_def: ChessPieceDef
var is_white: bool = true
var has_moved: bool = false
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

static var piece := preload("res://scenes/pieces/Piece.tscn")
static func instance(resource: ChessPieceDef, is_white: bool):
	var instance: ChessPiece = piece.instantiate()
	instance.piece_def = resource
	instance.texture = resource.white_texture
	instance.set_color(is_white)
	return instance

func _ready() -> void:
	piece_selected.connect(ChessGame.singleton._on_piece_selected)

func set_color(isWhitePiece: bool):
	if isWhitePiece:
		is_white = true
		modulate = Color.WHITE
	else: 
		is_white = false
		modulate = Color.DIM_GRAY

func get_direction_vectors() -> Array[Vector4i]:
	return piece_def.get_direction_vectors(is_white)

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	if not board.board_playable():
		return
	
	if not board.is_white == is_white:
		return
	
	piece_selected.emit(full_coord)
