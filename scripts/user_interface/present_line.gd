## Summary: UI element that indicates the currently playable timeline column.
class_name Present
extends ColorRect

@export var chess_logic: ChessLogic

var coord: int:
	set(val):
		coord = val
		recalculate_position()

var is_white: bool:
	get:
		return coord%2 == 0

func recalculate_position():
	self.position.x = coord * chess_logic.board_grid.cell_size().x
