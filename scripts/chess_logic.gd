class_name ChessLogic
extends Node

static var board := preload("res://Scenes/board.tscn")

signal boardstate_changed()
signal turn_changed(white_turn: bool)

var move_stack := []
const time_plus = Vector4i(1,0,0,0)
var is_white_turn: bool = true:
	set(val):
		is_white_turn = val
		turn_changed.emit(is_white_turn)
		
@onready var present = $PresentLine

func submit_turn() -> bool:
	calculate_present()
	if present.is_white == is_white_turn:
		return false
	move_stack.clear()
	is_white_turn = !is_white_turn
	return true

func undo():
	if move_stack.size() == 0: return
	var move_set = move_stack.pop_back()
	for move in move_set.values():
		move.queue_free()
	boardstate_changed.emit()


func _ready() -> void:
	boardstate_changed.connect(calculate_present)
	turn_changed.connect($"../ChessUI/TurnIndicator"._on_turn_changed)

func start_game():
	Board.new_board(self)
	boardstate_changed.emit()


func make_move(origin: Vector4i, dest: Vector4i):
	#create boards associated with move
	var dest_board = next_board(dest, true)
	var origin_board = next_board(origin)
	
	#remove any piece at destination
	var dest_piece = dest_board.get_piece(dest)
	if dest_piece != null: dest_piece.queue_free()
	
	dest_board.move_piece(origin_board.get_piece(origin), dest)
	
	#queue boards for undo
	var new_boards = {}
	new_boards[origin_board.coord] = origin_board
	new_boards[dest_board.coord] = dest_board
	move_stack.append(new_boards)
	
	clear_highlights()
	boardstate_changed.emit()


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
	var piece_to_move = get_piece(vec)
	for dir in piece_to_move.get_direction_vectors():
		var squareToMove = dir + vec
		var dims = Globals.dims_count(dir)
		var mag = 1
		while(coord_valid(squareToMove)):
			var dest_piece = get_piece(squareToMove)
			
			if dest_piece != null and dest_piece.is_white == piece_to_move.is_white:
				break
				
			if piece_to_move.piece_def.pawn:
				if dims == 1 and dest_piece != null: break
				if dims == 2 and dest_piece == null: break
				
			get_board(squareToMove).place_highlight(Vector2i(squareToMove.z,squareToMove.w))
			
			if dest_piece: break
			
			if piece_to_move.piece_def.rider or (piece_to_move.piece_def.pawn and !piece_to_move.has_moved and mag == 1):
				squareToMove += dir
				mag += 1
			else: 
				break

func clear_highlights():
	for square in get_tree().get_nodes_in_group("Highlight"):
		square.queue_free()

func calculate_present():
	var black = 0
	var white = 0
	for board in get_boards():
		if board.coord.y < black: 
			black = board.coord.y
		if board.coord.y > white: 
			white = board.coord.y
	var max = -black + 1
	var min = -white - 1
	var present_position: int = 1000000
	for active in get_boards().filter(func(b): return b.coord.y <= max and b.coord.y >= min and get_board(b.coord + Vector2i(1,0)) == null):
		if active.coord.x < present_position:
			present_position = active.coord.x
	present.coord = present_position

func coord_valid(piece_vec: Vector4i) -> bool:
	return not (piece_vec.z < 0 or piece_vec.z > 7 or piece_vec.w < 0 or piece_vec.w > 7 or get_board(piece_vec) == null)

func get_piece(vec: Vector4i):
	return get_board(vec).get_piece(vec)
	
func get_board(vec) -> Board:
	var boards = get_boards().filter(func(board): return Vector2i(vec.x, vec.y) == board.coord)
	assert(boards.size() < 2)
	if boards.size() != 1: return null
	return boards.front()

func get_boards() -> Array:
	var boards = get_tree().get_nodes_in_group("Board").filter(Globals.is_valid_node)
	return boards

## returns the proper line for a new timeline based on the original board coordinate
func new_line_position(coord) -> int:
	var isWhite = coord.x % 2 == 0
	var line := 0
	for board in get_tree().get_nodes_in_group("Board"):
		if (board.coord.y > line and isWhite) or (board.coord.y < line and not isWhite):
			line = board.coord.y
	return line + (1 if isWhite else -1)
