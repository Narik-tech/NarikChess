class_name Mod

extends Node

var chess: Chess:
	get:
		return get_parent()

func _ready():
	chess._on_starting_board_created.connect(_on_new_board)

func _on_new_board(board: Board):
	pass
  
