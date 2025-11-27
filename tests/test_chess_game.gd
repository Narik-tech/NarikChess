extends Node

const _ChessGame = preload("res://scenes/chess.tscn")

var _errors: Array[String] = []

func _ready():
	var args = OS.get_cmdline_args()
	if "--run-tests" in args:
		run_tests()
		get_tree().quit()
		return

func run_tests() -> bool:
	var chess_game : Chess = _ChessGame.instantiate()
	add_child(chess_game)

	#Test Base Mode	
	var from_coord := Vector4i(0, 0, 5, 1)
	chess_game._on_piece_selected(from_coord)
	_expect_equal(chess_game.selected_piece, from_coord, "_on_piece_selected should update the selected_piece value")

	var to_coord := Vector4i(0, 0, 5, 2)
	chess_game._on_piece_destination_selected(to_coord)
	chess_game._on_submit_pressed()
	_expect_true(chess_game.chess_client.get_piece(Vector4i(1, 0, 5, 2)) != null, "e3 should be occupied")
	_expect_true(chess_game.chess_client.get_piece(Vector4i(1, 0, 5, 1)) == null, "e2 should be empty")
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

	print("TestChessGame: FAIL")
	for error in _errors:
		print("TestFail: " + error)
	return false
