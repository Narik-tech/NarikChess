## Summary: Mod enabling classic single-board chess rules within the multiverse framework.
class_name Chess_2D
extends Mod

func _on_starting_board(_board: Board):
	chess.is_classic_chess = true
