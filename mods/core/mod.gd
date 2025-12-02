## Base mod hook that exposes board and move callbacks for gameplay extensions.

class_name Mod

extends Node

var chess: Chess:
	get:
		return get_parent()

var chess_logic: ChessLogic:
	get:
		return chess.chess_logic

func _ready():
	chess._on_starting_board_created.connect(_on_starting_board)
	chess._on_move_made.connect(_on_move_made)

func _on_starting_board(_board: Board):
	pass

func _on_move_made(_piece: Vector4i, _origin_board: Board, _dest_board: Board):
	pass

## If a move cannot be played, returns a string indicating why
func _can_play_move(origin: Vector4i, dest):
	return true

## If a turn cannot be submitted, returns a string indicating why
func _can_submit_turn():
	return true
