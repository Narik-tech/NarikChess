## Coordinates board state, turn flow, move execution, and legal move highlighting across timelines.
class_name ChessLogic
extends Node

signal _on_starting_board_created(board: Board)
signal _boardstate_changed()
signal _turn_changed(white_turn: bool)
signal _on_move_made(piece: Vector4i, origin_board: Board, dest_board: Board)

@export var board_grid: GameGrid
@export var present: ColorRect

var move_stack := []
const time_plus = Vector4i(1,0,0,0)
var is_white_turn: bool = true:
	set(val):
		is_white_turn = val
		_turn_changed.emit(is_white_turn)
		

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
	_boardstate_changed.emit()


func _ready() -> void:
	_boardstate_changed.connect(calculate_present)
	_turn_changed.connect($"../ChessUI/TurnIndicator"._on_turn_changed)

func start_game():
	var board = Board.inst(self)
	board_grid.place_control(board, Vector2i.ZERO)
	_on_starting_board_created.emit(board)
	_boardstate_changed.emit()


func make_move(origin: Vector4i, dest: Vector4i):
	#create boards associated with move
	var dest_board: Board = next_board(dest, true)
	var origin_board: Board = next_board(origin)
	
	#remove any piece at destination
	var dest_piece = dest_board.get_piece(dest)
	if dest_piece != null: dest_piece.queue_free()
	
	var piece_moving = origin_board.get_piece(origin)
	piece_moving.has_moved = true
	dest_board.place_piece(piece_moving, Vector2i(dest.z, dest.w))
	
	#queue boards for undo
	var new_boards = {}
	new_boards[origin_board.coord] = origin_board
	new_boards[dest_board.coord] = dest_board
	move_stack.append(new_boards)
	clear_highlights()
	
	_on_move_made.emit(piece_moving.full_coord, origin_board, dest_board)
	_boardstate_changed.emit()


## returns the next board in time, creating one if there isn't one
func next_board(orig_board, branch: bool = false):
	if orig_board is Vector4i:
		orig_board = Vector2i(orig_board.x, orig_board.y)
	var next_vec = orig_board + Vector2i.RIGHT
	var next = get_board(next_vec)
	if branch and next != null:
		next = get_board(orig_board).duplicate_board()
		board_grid.place_control(next, Vector2i(next_vec.x, new_line_position(orig_board)))
	
	if next == null:
		next = get_board(orig_board).duplicate_board()
		board_grid.place_control(next, next_vec)
	return next

func show_legal_moves(vec: Vector4i):
	clear_highlights()
	var piece_to_move = get_piece(vec)
	for dir in piece_to_move.get_direction_vectors():
		if Chess.singleton.is_classic_chess:
			if dir.x != 0 or dir.y != 0:
				continue
		
		var squareToMove = dir + vec
		var dims = Globals.dims_count(dir)
		var mag = 1
		while(coord_valid(squareToMove)):
			var dest_piece = get_piece(squareToMove)
			
			if dest_piece != null and dest_piece.blocks_movement(piece_to_move):
				break
				
			if piece_to_move.piece_def.pawn:
				if dims == 1 and dest_piece != null: break
				if dims == 2 and (dest_piece == null or dest_piece.is_overlay): break
#			
			var highlight = MoveHighlight.inst(Chess.singleton._on_piece_destination_selected)
			highlight.is_overlay = true
			get_board(squareToMove).place_piece(highlight, Vector2i(squareToMove.z,squareToMove.w))
			
			if dest_piece: break
			
			if piece_to_move.piece_def.rider or (piece_to_move.piece_def.pawn and !piece_to_move.has_moved and mag == 1):
				squareToMove += dir
				mag += 1
			else: 
				break

func clear_highlights():
	for square in get_tree().get_nodes_in_group("MoveHighlight"):
		square.queue_free()

func calculate_present():
	var black = 0
	var white = 0
	for board in get_boards():
		if board.coord.y < black: 
			black = board.coord.y
		if board.coord.y > white: 
			white = board.coord.y
	var max_line = -black + 1
	var min_line = -white - 1
	var present_position: int = 1000000
	
	var boards = get_boards()
	boards = boards.filter(func(b): return b.coord.y <= max_line)
	boards = boards.filter(func(b): return b.coord.y >= min_line)
	boards = boards.filter(func(b): return get_board(b.coord + Vector2i(1,0)) == null)
	
	for active in boards:
		if active.coord.x < present_position:
			present_position = active.coord.x
	#board_grid.place_control(present, Vector2i(present_position, 0), 0)
	present.coord = present_position

func coord_valid(piece_vec: Vector4i) -> bool:
	var board = get_board(piece_vec)
	if board == null: return false
	return board.piece_coord_valid(Vector2i(piece_vec.z,piece_vec.w))

func get_piece(vec: Vector4i) -> Piece:
	return get_board(vec).get_piece(vec)
	
func get_board(vec) -> Board:
	return board_grid.get_control(Vector2i(vec.x, vec.y))

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
