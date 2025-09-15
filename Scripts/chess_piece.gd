class_name ChessPiece
extends Piece

signal piece_selected(coord: Vector4i)

var piece_def: ChessPieceDef
var is_white: bool = true
var has_moved: bool = false


static var piece := preload("res://scenes/pieces/chess_piece.tscn")
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

func _on_click():
	if not board.board_playable():
		return
	
	if not board.is_white == is_white:
		return
	
	piece_selected.emit(full_coord)
