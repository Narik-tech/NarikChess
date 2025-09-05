extends Node

static var board := preload("res://Scenes/board.tscn")

#var chess_game: ChessGame
var move_stack := []
const time_plus = Vector4i(1,0,0,0)

func start_game():
	Board.new_board(self)


func make_move(origin: Vector4i, dest: Vector4i):
	var dest_board = next_board(dest, true)
	var origin_board = next_board(origin)
	dest_board.move_piece(get_piece(origin + time_plus), dest)
	
	#queue for undo
	var new_boards = {}
	new_boards[origin_board.coord] = origin_board
	new_boards[dest_board.coord] = dest_board
	move_stack.append(new_boards)
	clear_highlights()


## returns the next board in time, creating one if there isn't one
func next_board(orig_board: Vector4i, branch: bool = false):
	var next_vec = orig_board + time_plus
	var next = get_board(next_vec)
	if branch and next != null:
		next = get_board(orig_board).duplicate_board(Vector2i(next_vec.x, new_line_position(orig_board)))
		self.add_child(next)
	
	if next == null:
		next = get_board(orig_board).duplicate_board(next_vec)
		self.add_child(next)
	return next

func show_legal_moves(vec: Vector4i):
	clear_highlights()
	for dir in get_piece(vec).getDirectionVectors():
		var squareToMove = dir + vec
		while(coord_valid(squareToMove)):
			get_board(squareToMove).place_highlight(Vector2i(squareToMove.z,squareToMove.w))
			squareToMove += dir

func clear_highlights():
	for square in get_tree().get_nodes_in_group("Highlight"):
		square.queue_free()

func coord_valid(piece_vec: Vector4i) -> bool:
	return not (piece_vec.z < 0 or piece_vec.z > 7 or piece_vec.w < 0 or piece_vec.w > 7 or get_board(piece_vec) == null)

func get_piece(vec: Vector4i):
	var arr = get_tree().get_nodes_in_group("Piece").filter(func(piece): return vec == piece.full_coord)
	if arr.size() == 1:
		return arr[0]
	return null
	
func get_board(vec) -> Board:
	var arr = get_tree().get_nodes_in_group("Board").filter(func(board): return Vector2i(vec.x, vec.y) == board.coord)
	if arr.size() == 1:
		return arr[0]
	return null

## returns the proper line for a new timeline based on the original board coordinate
func new_line_position(coord) -> int:
	var isWhite = coord.x % 2 == 0
	var line := 0
	for board in get_tree().get_nodes_in_group("Board"):
		if (board.coord.y < line and isWhite) or (board.coord.y < line and not isWhite):
			line = board.coord.y
	return line + (1 if isWhite else -1)
