class_name MoveHandling
extends Node

@export var game_state: GameState
@export var move_legality: MoveLegality

var move_generators: Array[MoveGenerator]

signal _move_started()
signal _move_completed()
signal _on_chess_move(_piece: Vector4i, _origin_board: Board, _dest_board: Board)

func _ready():
	move_generators.append(StraightMoveGen.new())
	move_generators.append(PawnMoveGen.new())
	
func space_selected(position: Vector4i, piece: Piece):
	if not move_legality.piece_selectable(position, piece):
		return false
	if piece is ChessPiece:
		show_legal_moves(position, piece)
	if piece is MoveHighlight:
		make_move((piece as MoveHighlight).highlight_action)

func make_move(move_call: Callable, undo_callback = null):
	_move_started.emit()
	var result = move_call.call()
	if undo_callback is Callable and game_state.staged_undos.size() > 0:
		game_state.staged_undos.append(undo_callback)
	_move_completed.emit()
	return result

func show_legal_moves(start_pos: Vector4i, piece: ChessPiece):
	clear_highlights()
	var moves: Array[Move]
	for generator in move_generators:
		moves.append_array(generator.get_moves(game_state, start_pos, piece))
	for move in moves:
		var highlight = MoveHighlight.inst(chess_move.bind(move))	
		highlight.is_overlay = true
		game_state.place_piece(highlight, move.end_position, 1)

func chess_move(move: Move):
	var time_plus := Vector4i(1,0,0,0)
	var dest_board: Board = next_board(move.end_position, true)
	var orig_board: Board = next_board(move.start_position)
	var piece_moving = game_state.get_piece(move.start_position + time_plus)
	for piece in move.pieces_to_take:
		game_state.remove_piece(Vector4i(dest_board.coord.x, dest_board.coord.y, piece.coord.x, piece.coord.y))
	piece_moving.has_moved = true
	var piece_place_position := Vector4i(dest_board.coord.x, dest_board.coord.y, move.end_position.z, move.end_position.w)
	game_state.place_piece(piece_moving, piece_place_position)
	_on_chess_move.emit(piece_place_position, orig_board, dest_board)
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
