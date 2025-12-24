class_name  DuckSubmitTurnCriteria
extends SubmitTurnCriteria

const duck_meta_string = "prev_duck"

func can_submit_turn(board_game: BoardGame, _turn_handling: TurnHandling) -> bool:
	for board in board_game.game_state.all_boards():
		var duck_moved := has_duck_moved(board)
		if duck_placable(board_game, board) and not duck_moved:
			return false
	return true

func has_duck_moved(board: Board) -> bool:
	var duck_array = board.all_pieces().filter(func(c): return c is DuckPiece)
	var duck
	if duck_array.size() > 0:
		duck = duck_array[0]
	if not board.has_meta(duck_meta_string): return false
	if duck.coord == board.get_meta(duck_meta_string):
		return false
	return true

func duck_placable(board_game: BoardGame, board: Board) -> bool:
	if board.is_white == board_game.turn_handling.is_white_turn:
		return false
	if board_game.game_state.get_board(board.coord + Vector2i.RIGHT) != null:
		return false
	return true
