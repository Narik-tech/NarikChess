## Represents a movable chess piece with color, movement rules, and selection handling.
class_name ChessPiece
extends Piece

signal piece_selected(coord: Vector4i)

var piece_def: ChessPieceDef
var is_white: bool = true
var has_moved: bool = false

static var pawn := preload("res://piece_definitions/pawn.tres")
static var bishop := preload("res://piece_definitions/bishop.tres")
static var knight := preload("res://piece_definitions/knight.tres")
static var rook := preload("res://piece_definitions/rook.tres")
static var king := preload("res://piece_definitions/king.tres")
static var queen := preload("res://piece_definitions/queen.tres")

static func inst(resource: ChessPieceDef, white: bool) -> ChessPiece:
	var instance = Piece.texture_inst(resource.white_texture, ChessPiece)
	instance.piece_def = resource
	instance.set_color(white)
	return instance
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return _piece_moving.is_white == self.is_white

func piece_ready() -> void:
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
