extends Mod
#duck logic will need updated if multi-board starting variants are added

const duck_meta_string = "prev_duck"

#Before playing a move, require the player to place a duck on the board if it has no duck
func _can_play_move(origin: Vector4i, _dest):
	var origin_board: Board = chess_logic.get_board(origin)
	var duck_on_origin = origin_board.all_pieces().any(func (child): return child is DuckPiece)
	if duck_on_origin == true: return true
	return "Duck must be placed before playing a move"

#Only allow turn submission if the duck on each board is at a different location to the preceding board
func _can_submit_turn():
	for board in chess_logic.get_boards():
		var duck_moved = has_duck_moved(board)
		if duck_placable(board) and duck_moved is String:
			return duck_moved
	return true

func _on_move_made(_piece: Vector4i, _origin_board: Board, _dest_board: Board):
	set_duck_meta(_origin_board)
	if _dest_board != _origin_board: set_duck_meta(_dest_board)

func has_duck_moved(board: Board):
	var duck_array = board.all_pieces().filter(func(c): return c is DuckPiece)
	var duck
	if duck_array.size() > 0:
		duck = duck_array[0]
	if not board.has_meta(duck_meta_string): return false
	if duck.coord == board.get_meta(duck_meta_string):
		return "Duck at " + Globals.v4i_to_5d_coord(duck.full_coord) + " must move before turn can be submitted"
	return true

func set_duck_meta(board: Board):
	var duck = board.all_pieces().filter(func(c): return c is DuckPiece)[0]
	board.set_meta(duck_meta_string, duck.coord)

func _on_starting_board(_board: Board):
	highlight_valid_duck_squares(_board)

func highlight_valid_duck_squares(board: Board):
	for x in 8: for y in 8:
		if board.get_piece(Vector2i(x,y)) == null:
			board.place_piece(MoveHighlight.inst(place_duck), Vector2i(x,y))

func place_duck(coord: Vector4i):
	#remove any existing ducks
	for duck in chess_logic.get_board(coord).all_pieces().filter(func (child): return child is DuckPiece):
		duck.queue_free()
	
	#new duck
	chess_logic.clear_highlights()
	var board = chess_logic.get_board(coord)
	var duck: Piece = DuckPiece.inst()
	duck.on_piece_clicked.connect(_on_duck_clicked, 2)
	board.place_piece(duck, coord)

func _on_duck_clicked(duck: Vector4i):
	var board = chess_logic.get_board(duck)
	if duck_placable(board):
		highlight_valid_duck_squares(board)

func duck_placable(board: Board) -> bool:
	if board.is_white == chess_logic.is_white_turn:
		return false
	if chess_logic.get_board(board.coord + board.time_plus) != null:
		return false
	return true
