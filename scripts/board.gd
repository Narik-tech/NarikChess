## Represents a single board instance, managing piece placement, duplication, and spatial attributes.
class_name Board
extends Node

@export var board_grid: GameGrid 

static var board_interval = 480
const time_plus = Vector2i(1,0)
const board_size = 8
const block_pixel_size = 60

var coord: Vector2i:
	set(val):
		coord = val
		recalculateBoardPosition()

var is_white: bool:
	get:
		return coord.x % 2 == 0

var chess_logic: ChessLogic:
	get:
		return get_parent()

static var board_scene := preload("res://scenes/board.tscn")

##instances a board under the provided parent
static func new_board(parent: Node):
	var instance = board_scene.instantiate()
	instance.createBaseBoard()
	parent.add_child(instance)
	Chess.singleton.on_starting_board_created.emit(instance)
	return instance

func all_pieces() -> Array:
	return board_grid.all_controls()

func board_playable() -> bool:
	if is_white != chess_logic.is_white_turn:
		return false
	if chess_logic.get_board(coord + time_plus) != null:
		return false
	return true

func duplicate_board(coord) -> Board:
	var instance: Board = board_scene.instantiate()
	instance.coord = Vector2i(coord.x, coord.y)
	for piece in all_pieces():
		if piece is Piece:
			if piece is ChessPiece:
				var new_piece = ChessPiece.inst(piece.piece_def, piece.is_white)
				new_piece.has_moved = piece.has_moved
				instance.place_piece(new_piece, piece.coord)
			elif not piece.is_overlay:
				var new_piece = piece.duplicate()
				instance.place_piece(new_piece, piece.coord)
	return instance

func get_piece(vec) -> Piece:
	return board_grid.get_control(piece_coord(vec))

func recalculateBoardPosition():
	var vec =  Vector2i(coord.x * board_interval, coord.y * board_interval)
	self.position = vec
	$BoardOutline.color = Color.LIGHT_GRAY if is_white else Color.DIM_GRAY

func place_piece(piece: Piece, place_coord, layer = null) -> bool:
	if layer is int:
		board_grid.place_control(piece, piece_coord(place_coord), layer)
	return board_grid.place_control(piece, piece_coord(place_coord), 1 if piece.is_overlay else 0)

func piece_coord(vec) -> Vector2i:
	if vec is Vector2i: return vec
	if vec is Vector4i: return Vector2i(vec.z, vec.w)
	assert(false)
	return Vector2i.ZERO

func createBaseBoard():
	# Place pawns
	for x in 8:
		place_piece(ChessPiece.inst(ChessPiece.pawn, false), Vector2i(x, 1)) # Black pawns
		place_piece(ChessPiece.inst(ChessPiece.pawn, true), Vector2i(x, 6)) # White pawns

	# Place rooks
	place_piece(ChessPiece.inst(ChessPiece.rook, false), Vector2i(0, 0))
	place_piece(ChessPiece.inst(ChessPiece.rook, false), Vector2i(7, 0))
	place_piece(ChessPiece.inst(ChessPiece.rook, true), Vector2i(0, 7))
	place_piece(ChessPiece.inst(ChessPiece.rook, true), Vector2i(7, 7))

	# Place knights
	place_piece(ChessPiece.inst(ChessPiece.knight, false), Vector2i(1, 0))
	place_piece(ChessPiece.inst(ChessPiece.knight, false), Vector2i(6, 0))
	place_piece(ChessPiece.inst(ChessPiece.knight, true), Vector2i(1, 7))
	place_piece(ChessPiece.inst(ChessPiece.knight, true), Vector2i(6, 7))

	# Place bishops
	place_piece(ChessPiece.inst(ChessPiece.bishop, false), Vector2i(2, 0))
	place_piece(ChessPiece.inst(ChessPiece.bishop, false), Vector2i(5, 0))
	place_piece(ChessPiece.inst(ChessPiece.bishop, true), Vector2i(2, 7))
	place_piece(ChessPiece.inst(ChessPiece.bishop, true), Vector2i(5, 7))

	# Place queens
	place_piece(ChessPiece.inst(ChessPiece.queen, false), Vector2i(3, 0))
	place_piece(ChessPiece.inst(ChessPiece.queen, true), Vector2i(3, 7))

	# Place kings
	place_piece(ChessPiece.inst(ChessPiece.king, false), Vector2i(4, 0))
	place_piece(ChessPiece.inst(ChessPiece.king, true), Vector2i(4, 7))

func _on_game_grid_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = board_grid.mouse_coord()
			if get_piece(local_pos) == null:
				Chess.singleton.on_empty_space_selected.emit(self, Vector2i(floor(local_pos.x), floor(local_pos.y)))
