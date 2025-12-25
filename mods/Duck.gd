extends Mod
#duck logic will need updated if multi-board starting variants are added

const duck_meta_string = "prev_duck"

func _ready():
	super()
	board_game.turn_handling._submit_turn_criteria.append(DuckSubmitTurnCriteria.new())

#Before playing a move, require the player to place a duck on the board if it has no duck
func _can_play_move(origin: Vector4i, _dest):
	var origin_board: Board = game_state.get_board(origin)
	var duck_on_origin = origin_board.all_pieces().any(func (child): return child is DuckPiece)
	if duck_on_origin == true: return true
	return "Duck must be placed before playing a move"

func _on_move_made(_piece: Vector4i, _origin_board: Board, _dest_board: Board):
	set_duck_meta(_origin_board)
	if _dest_board != _origin_board: set_duck_meta(_dest_board)

func set_duck_meta(board: Board):
	var duck = board.all_pieces().filter(func(c): return c is DuckPiece)[0]
	board.set_meta(duck_meta_string, duck.coord)

func _on_starting_board(_board: Board):
	highlight_valid_duck_squares(_board)

func highlight_valid_duck_squares(board: Board):
	for x in 8: for y in 8:
		if board.get_piece(Vector2i(x,y)) == null:
			var duck_pos = Vector2i(x,y)
			board.place_piece(MoveHighlight.inst(place_duck.bind(board, duck_pos)), duck_pos)

func place_duck(board: Board, coord: Vector2i):
	#remove any existing ducks
	for duck in board.piece_grid.all_controls().filter(func (child): return child is DuckPiece):
		game_state.remove_piece(Vector4i(board.coord.x, board.coord.y, duck.coord.x, duck.coord.y))
	
	board_game.move_handling.clear_highlights()
	board.place_piece(DuckPiece.inst(), coord)

func _on_space_selected(_position: Vector4i, _piece: Control):
	if _piece is DuckPiece: _on_duck_clicked(_position)

func _on_duck_clicked(duck: Vector4i):
	var board = game_state.get_board(duck)
	if duck_placable(board):
		highlight_valid_duck_squares(board)

func duck_placable(board: Board) -> bool:
	if board.is_white == board_game.turn_handling.is_white_turn:
		return false
	if game_state.get_board(board.coord + Vector2i.RIGHT) != null:
		return false
	return true
