class_name MoveHandling
extends Node

@export var game_state: GameState

signal _move_started()
signal _move_completed()

func space_selected(position: Vector4i, piece: Piece):
	if piece is ChessPiece:
		show_legal_moves(position, piece)
	if piece is MoveHighlight:
		make_move((piece as MoveHighlight).highlight_action)

func make_move(move_call: Callable):
	_move_started.emit()
	move_call.call()
	_move_completed.emit()

func show_legal_moves(vec: Vector4i, piece: ChessPiece):
	clear_highlights()
	for dir in piece.get_direction_vectors():
		#if Chess.singleton.is_classic_chess:
			#if dir.x != 0 or dir.y != 0:
				#continue
		var squareToMove = dir + vec
		var dims = Globals.dims_count(dir)
		var mag = 1
		while(game_state.coord_valid(squareToMove)):
			var dest_piece = game_state.get_piece(squareToMove)
			if dest_piece != null and dest_piece.blocks_movement(piece):
				break
				
			if piece.piece_def.pawn:
				if dims == 1 and dest_piece != null: break
				if dims == 2 and (dest_piece == null or dest_piece.is_overlay): break
#			
			var highlight = MoveHighlight.inst(chess_move.bind(vec, squareToMove))
			highlight.is_overlay = true
			game_state.place_piece(highlight, squareToMove, 1)
			
			if dest_piece: break
			
			if piece.piece_def.rider or (piece.piece_def.pawn and !piece.has_moved and mag == 1):
				squareToMove += dir
				mag += 1
			else: 
				break

func chess_move(origin: Vector4i, dest: Vector4i):
	var time_plus := Vector4i(1,0,0,0)
	#create boards associated with move
	var dest_board: Board = next_board(dest, true)
	var origin_board: Board = next_board(origin)
	
	#remove any piece at destination
	#var dest_piece = dest_board.get_piece(dest)
	#if dest_piece != null: dest_piece.queue_free()
	
	#var piece_moving = origin_board.get_piece(origin)
	var piece_moving = game_state.get_piece(origin + time_plus)
	piece_moving.has_moved = true
	game_state.place_piece(piece_moving, Vector4i(dest_board.coord.x, dest_board.coord.y, dest.z, dest.w))
	
	#queue boards for undo
	#var new_boards = {}
	#new_boards[origin_board.coord] = origin_board
	#new_boards[dest_board.coord] = dest_board
	clear_highlights()

## returns the next board in time, creating one if there isn't one
func next_board(orig_board, branch: bool = false):
	if orig_board is Vector4i:
		orig_board = Vector2i(orig_board.x, orig_board.y)
	var next_vec = orig_board + Vector2i.RIGHT
	var next = game_state.get_board(next_vec)
	if branch and next != null:
		next = game_state.get_board(orig_board).duplicate_board()
		game_state.place_board(next, Vector2i(next_vec.x, new_line_position(orig_board)))
	
	if next == null:
		next = game_state.get_board(orig_board).duplicate_board()
		game_state.place_board(next, next_vec)
	return next

func clear_highlights():
	for square in get_tree().get_nodes_in_group("MoveHighlight"):
		square.queue_free()

## returns the proper line for a new timeline based on the original board coordinate
func new_line_position(coord) -> int:
	var isWhite = coord.x % 2 == 0
	var line := 0
	for board in get_tree().get_nodes_in_group("Board"):
		if (board.coord.y > line and isWhite) or (board.coord.y < line and not isWhite):
			line = board.coord.y
	return line + (1 if isWhite else -1)
