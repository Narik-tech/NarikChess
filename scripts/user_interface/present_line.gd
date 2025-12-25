## Summary: UI element that indicates the currently playable timeline column.
class_name Present
extends ColorRect

var coord: int

var is_white: bool:
	get:
		return coord%2 == 0

func _on_game_state_changed(game_state: GameState):
	var black = 0
	var white = 0
	for board in game_state.board_grid.all_controls():
		if board.coord.y < black: 
			black = board.coord.y
		if board.coord.y > white: 
			white = board.coord.y
	var max_line = -black + 1
	var min_line = -white - 1
	var present_position: int = 1000000
	
	var boards = game_state.board_grid.all_controls()
	boards = boards.filter(func(b): return b.coord.y <= max_line)
	boards = boards.filter(func(b): return b.coord.y >= min_line)
	boards = boards.filter(func(b): return game_state.get_board(b.coord + Vector2i(1,0)) == null)
	
	for active in boards:
		if active.coord.x < present_position:
			present_position = active.coord.x
	coord = present_position
	self.position.x = coord * game_state.board_grid.cell_size().x
