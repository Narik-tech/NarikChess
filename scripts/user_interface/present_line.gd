# Summary: UI element that indicates the currently playable timeline column.
class_name Present
extends ColorRect

var coord: int:
	set(val):
		coord = val
		recalculate_position()

var is_white: bool:
	get:
		return coord%2 == 0

func recalculate_position():
	self.position.x = coord * Board.board_interval
