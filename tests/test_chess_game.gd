## Summary: Basic integration test harness that simulates a move and reports pass or fail.
extends Node

const _ChessGame = preload("res://scenes/chess.tscn")

var _errors: Array[String] = []

var board_game: BoardGame 
var current_test: String

var example_pgn: String='[Mode "5D"] [Result "1-0"] [Date "2025.11.27"] [Time "09:09:07 (+05:30)"] [Size "8x8"] [White "recon"] [Black "SweepingBishops"] [Board "custom"] [r*nbqk*bnr*/p*p*p*p*p*p*p*p*/8/8/8/8/P*P*P*P*P*P*P*P*/R*NBQK*BNR*:0:0:b] [r*nbqk*bnr*/p*p*p*p*p*p*p*p*/8/8/8/8/P*P*P*P*P*P*P*P*/R*NBQK*BNR*:0:1:w] 1.{20:05}(0T1)Ng1f3 / {20:05}(0T1)Ng8f6 2.{20:05}(0T2)c2c4 / {19:14}(0T2)c7c5 3.{19:17}(0T3)e2e3 / {19:11}(0T3)Nb8c6 4.{19:06}(0T4)Nb1c3 / {18:12}(0T4)Qd8c7'
func _ready():
	var parsedpgn = FiveDPGN.parse_string(example_pgn)
	var args = OS.get_cmdline_args()
	if "--run-tests" in args:
		run_tests()
		get_tree().quit()
		return

func run_tests() -> bool:
	run_test("e_pawn_move_test")
	run_test("en_passant_test")
	return _report()

func e_pawn_move_test():
	select_space(Vector4i(0, 0, 5, 6))
	select_space(Vector4i(0, 0, 5, 5))
	board_game.turn_handling._on_submit_pressed()
	_expect_true(board_game.game_state.get_piece(Vector4i(1, 0, 5, 5)) != null, "e3 should be occupied")
	_expect_true(board_game.game_state.get_piece(Vector4i(1, 0, 5, 6)) == null, "e2 should be empty")

func en_passant_test():
	select_space(Vector4i(0, 0, 4, 6))
	select_space(Vector4i(0, 0, 4, 4))
	board_game.turn_handling._on_submit_pressed()
	
	select_space(Vector4i(1, 0, 0, 1))
	select_space(Vector4i(1, 0, 0, 2))
	board_game.turn_handling._on_submit_pressed()
	
	select_space(Vector4i(2, 0, 4, 4))
	select_space(Vector4i(2, 0, 4, 3))
	board_game.turn_handling._on_submit_pressed()
	
	select_space(Vector4i(3, 0, 5, 1))
	select_space(Vector4i(3, 0, 5, 3))
	board_game.turn_handling._on_submit_pressed()
	
	select_space(Vector4i(4, 0, 4, 3))
	select_space(Vector4i(4, 0, 5, 2))
	board_game.turn_handling._on_submit_pressed()
	
	_expect_true(board_game.game_state.get_piece(Vector4i(5, 0, 5, 2)) != null, "f6 should be occupied")
	_expect_true(board_game.game_state.get_piece(Vector4i(5, 0, 4, 3)) == null, "e5 should be empty")
	_expect_true(board_game.game_state.get_piece(Vector4i(5, 0, 5, 3)) == null, "f5 should be empty")

func run_test(test_name: String):
	_test_init()
	current_test = test_name
	call(test_name)
	_test_cleanup()

func _test_init():
	board_game = _ChessGame.instantiate()
	add_child(board_game)

func _test_cleanup():
	board_game.queue_free()
	board_game = null

func select_space(position: Vector4i):
	var piece = board_game.game_state.get_piece(position)
	board_game.on_space_selected(position, piece)
	await get_tree().process_frame

func _expect_true(condition: bool, message: String) -> void:
	if not condition:
		_log_failure(message)

func _log_failure(message: String):
	_errors.append("Failure in " + current_test + ": " + message)

func _report() -> bool:
	if _errors.is_empty():
		print("TestChessGame: PASS")
		return true

	print("TestChessGame: FAIL")
	for error in _errors:
		print(error)
	return false
