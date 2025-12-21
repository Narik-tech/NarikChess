##Handles changes to the game state.
class_name GameState
extends Node

### Piece Coords ###
#### (T,L,x,y)  ####

signal _space_selected(position: Vector4i, piece: Control)
signal _game_state_changed(game_state: GameState)

var undo_queue: Array[MoveToUndo]

class MoveToUndo:
	var undo_calls: Array[Callable]

@export var board_grid: GameGrid

func get_board(position) -> Board:
	return board_grid.get_control(Vector2i(position.x, position.y))

func get_piece(position: Vector4i):
	var board = get_board(position)
	return board.get_piece(position)

func place_board(board: Board, position: Vector2i) -> bool:
	board._space_selected.connect(_on_board_space_selected)
	var success = board_grid.place_control(board, position)
	if success: _game_state_changed.emit(self)
	return success

func place_piece(piece: Piece, position: Vector4i, layer: int = 0) -> bool:
	var board = get_board(position)
	var success = board.piece_grid.place_control(piece, Vector2i(position.z, position.w), layer if layer is int else 1 if piece.is_overlay else 0)
	_game_state_changed.emit(self)
	return success

func remove_board(position: Vector2i):
	get_board(position).queue_free()
	_game_state_changed.emit(self)

func remove_piece(position: Vector4i):
	get_piece(position).queue_free()
	_game_state_changed.emit(self)

func _on_board_space_selected(position: Vector4i, control: Control):
	_space_selected.emit(position, control)

func coord_valid(piece_vec: Vector4i) -> bool:
	var board = get_board(piece_vec)
	if board == null: return false
	return board.piece_coord_valid(Vector2i(piece_vec.z,piece_vec.w))

func undo_move():
	pass
