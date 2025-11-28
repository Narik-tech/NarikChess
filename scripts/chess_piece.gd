class_name ChessPiece
extends Piece

signal piece_selected(coord: Vector4i)

var piece_def: ChessPieceDef
var is_white: bool = true
var has_moved: bool = false


static var piece := preload("res://scenes/pieces/chess_piece.tscn")

static func inst(resource: ChessPieceDef, white: bool) -> ChessPiece:
	var instance: ChessPiece = piece.instantiate()
	instance.piece_def = resource
	instance.texture = resource.white_texture
	instance.set_color(white)
	return instance
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return _piece_moving.is_white == self.is_white

func _ready() -> void:
	piece_selected.connect(Chess.singleton._on_piece_selected)

func set_color(isWhitePiece: bool):
	if isWhitePiece:
		is_white = true
		modulate = Color.WHITE
	else: 
		is_white = false
		modulate = Color.DIM_GRAY

func get_direction_vectors() -> Array[Vector4i]:
	return piece_def.get_direction_vectors(is_white)

func _on_click():
	if not board.board_playable():
		return
	
	if not board.is_white == is_white:
		return
	
	piece_selected.emit(full_coord)
