## Summary: Base mod hook that exposes board and move callbacks for gameplay extensions.
## All scripts extending Mod automatically added as selectable option
## Override functions to determine mod functionality
class_name Mod

extends Node

var chess: Chess:
	get:
		return get_parent()

func _ready():
	chess._on_starting_board_created.connect(_on_starting_board)
	chess._on_move_made.connect(_on_move_made)

func _on_starting_board(_board: Board):
	pass

func _on_move_made(_piece: Piece, _origin_board: Board, _dest_board: Board):
	pass
