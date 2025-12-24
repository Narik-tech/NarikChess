##Handles changes to the game state.
class_name GameState
extends Node

### Piece Coords ###
#### (T,L,x,y)  ####

signal _space_selected(position: Vector4i, piece: Control)
signal _game_state_changed(game_state: GameState)

@export var classic_chess: bool 
var undo_queue: Array[MoveToUndo] = []
var staged_undos: Array[Callable] = []

class MoveToUndo:
	var undo_calls: Array[Callable]

@export var board_grid: GameGrid

func get_board(position) -> Board:
	return board_grid.get_control(Vector2i(position.x, position.y))

func get_piece(position: Vector4i, layer: int = -1) -> Piece:
	var board = get_board(position)
	if board == null: return
	return board.get_piece(position, layer)

func place_board(board: Board, position: Vector2i) -> bool:
	board._space_selected.connect(_on_board_space_selected)
	var success = board_grid.place_control(board, position)
	if success:
		staged_undos.append(Callable(self, "remove_board").bind(position))
		_game_state_changed.emit(self)
	return success

func place_piece(piece: Piece, position: Vector4i, layer: int = 0) -> bool:
	var board = get_board(position)
	var computed_layer: int = layer if layer is int else (1 if piece.is_overlay else 0)

	var success = board.piece_grid.place_control(
		piece,
		Vector2i(position.z, position.w),
		computed_layer
	)
	if success:
		staged_undos.append(Callable(self, "remove_piece").bind(position))
		_game_state_changed.emit(self)
	return success


func remove_board(position: Vector2i):
	var board := get_board(Vector4i(position.x, position.y, 0, 0))
	if board != null:
		# undo(remove) = place a duplicate back
		var board_copy = board.duplicate(DUPLICATE_USE_INSTANTIATION + DUPLICATE_SCRIPTS)
		staged_undos.append(Callable(self, "place_board").bind(board_copy, position))
		board.queue_free()
		_game_state_changed.emit(self)

func remove_piece(position: Vector4i):
	var piece = get_piece(position)
	if piece != null:
		var piece_copy = piece.duplicate(DUPLICATE_USE_INSTANTIATION + DUPLICATE_SCRIPTS)
		staged_undos.append(Callable(self, "place_piece").bind(piece_copy, position, piece_copy.z_index))
		piece.queue_free()
		_game_state_changed.emit(self)

func all_boards() -> Array:
	return board_grid.all_controls()

func _on_board_space_selected(position: Vector4i, control: Control):
	_space_selected.emit(position, control)

func coord_valid(piece_vec: Vector4i) -> bool:
	var board = get_board(piece_vec)
	if board == null: return false
	return board.piece_coord_valid(Vector2i(piece_vec.z,piece_vec.w))

func undo_move() -> bool:
	var undo = undo_queue.pop_back()
	if undo == null: return false
	undo.undo_calls.reverse()
	for callable: Callable in undo.undo_calls:
		callable.call()
	return true

func _on_move_handling_move_started() -> void:
	staged_undos.clear()

func _on_move_handling_move_completed() -> void:
	var move_to_undo = MoveToUndo.new()
	move_to_undo.undo_calls = staged_undos.duplicate_deep()
	staged_undos.clear()
	undo_queue.push_back(move_to_undo)

func _on_turn_changed(white_turn: bool):
	undo_queue.clear()
