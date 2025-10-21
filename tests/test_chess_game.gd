extends Node

const _ChessGame = preload("res://Scripts/chess.gd")

class StubChessLogicScene:
	var last_instance: StubChessLogic = null

	func instantiate() -> StubChessLogic:
		last_instance = StubChessLogic.new()
		return last_instance

class StubChessLogic:
	extends Node

	var started := false
	var show_legal_moves_calls: Array = []
	var make_move_calls: Array = []
	var submit_turn_count := 0

	func start_game() -> void:
		started = true

	func show_legal_moves(coord: Vector4i) -> void:
		show_legal_moves_calls.append(coord)

	func make_move(from_coord: Vector4i, to_coord: Vector4i) -> void:
		make_move_calls.append([from_coord, to_coord])

	func submit_turn() -> void:
		submit_turn_count += 1

	func undo() -> void:
		pass

var _errors: Array[String] = []

func run() -> bool:
	var original_scene = ChessGame.chess_logic
	var stub_scene := StubChessLogicScene.new()
	ChessGame.chess_logic = stub_scene

	var chess_game := _ChessGame.new()
	add_child(chess_game)
	chess_game.game_start()

	var chess_logic := stub_scene.last_instance
	_expect_true(chess_logic != null, "game_start should instantiate the chess logic scene")
	_expect_true(chess_logic != null and chess_logic.started, "game_start should call start_game on the chess logic")

	var from_coord := Vector4i(0, 0, 5, 1)
	chess_game._on_piece_selected(from_coord)
	_expect_equal(chess_game.selected_piece, from_coord, "_on_piece_selected should update the selected_piece value")
	_expect_equal(chess_logic.show_legal_moves_calls, [from_coord], "_on_piece_selected should forward the selection to the chess logic")

	var to_coord := Vector4i(0, 0, 5, 2)
	chess_game._on_piece_destination_selected(to_coord)
	_expect_equal(chess_logic.make_move_calls, [[from_coord, to_coord]], "_on_piece_destination_selected should request the move from the chess logic")

	chess_game._on_submit_pressed()
	_expect_equal(chess_logic.submit_turn_count, 1, "_on_submit_pressed should submit the turn exactly once")

	ChessGame.chess_logic = original_scene
	chess_game.queue_free()

	return _report()

func _expect_true(condition: bool, message: String) -> void:
	if not condition:
		_errors.append(message)

func _expect_equal(actual, expected, message: String) -> void:
	if actual != expected:
		_errors.append("%s (expected: %s, got: %s)" % [message, str(expected), str(actual)])

func _report() -> bool:
	if _errors.is_empty():
		print("TestChessGame: PASS")
		return true

	for error in _errors:
		push_error(error)
	return false
