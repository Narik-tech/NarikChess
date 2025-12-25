## Represents a single board instance, managing piece placement, duplication, and spatial attributes.
class_name Board
extends Control

signal _space_selected(position: Vector4i, piece: Control)

@export var piece_grid: GameGrid 

var coord: Vector2i:
	get:
		return get_meta("coord")

var is_white: bool:
	get:
		return coord.x % 2 == 0

var game_state: GameState

static var board_scene := preload("res://scenes/board.tscn")

##instances a board
static func inst(_game_state: GameState) -> Board:
	var instance: Board = board_scene.instantiate()
	instance.game_state = _game_state
	return instance

func all_pieces() -> Array:
	return piece_grid.all_controls()

func duplicate_board() -> Board:
	var instance: Board = board_scene.instantiate()
	instance.game_state = game_state
	for piece in all_pieces():
		if piece is Piece:
			if piece is ChessPiece:
				var new_piece = ChessPiece.inst(piece.piece_def, piece.is_white)
				new_piece.has_moved = piece.has_moved
				instance.piece_grid.place_control(new_piece, piece.coord)
			elif not piece.is_overlay:
				var new_piece = piece.duplicate()
				instance.piece_grid.place_control(new_piece, piece.coord)
	return instance

func get_piece(vec, layer: int = -1) -> Piece:
	return piece_grid.get_control(piece_coord(vec), layer)

func place_piece(piece: Piece, _position, layer: int = 0):
	_position = piece_coord(_position)
	game_state.place_piece(piece, Vector4i(coord.x, coord.y,_position.x, _position.y), layer)

func _ready():
	$BoardOutline.color = Color.LIGHT_GRAY if is_white else Color.DIM_GRAY

func piece_coord(vec) -> Vector2i:
	if vec is Vector2i: return vec
	if vec is Vector4i: return Vector2i(vec.z, vec.w)
	assert(false)
	return Vector2i.ZERO

func piece_coord_valid(vec: Vector2i):
	return piece_grid.coord_in_range(vec)

func _on_piece_grid_space_selected(space_pos: Vector2i, control: Control) -> void:
	_space_selected.emit(Vector4i(coord.x,coord.y,space_pos.x,space_pos.y), control)
