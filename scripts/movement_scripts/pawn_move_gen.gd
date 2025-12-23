class_name PawnMoveGen
extends MoveGenerator

func get_moves(game_state: GameState, start_pos, piece: ChessPiece) -> Array[Move]:
	if not piece.piece_def.pawn: return []
	var base_moves: Array[Move] = simple_move_gen(game_state, start_pos, piece)
	var final_moves: Array[Move]
	for move in base_moves:
		var dir = move.end_position - move.start_position
		var dims = Globals.dims_count(dir)
		#orthagonal
		if dims == 1:
			if move.pieces_to_take.size() > 0: continue
			#move two on first movement
			if not piece.has_moved:
				var double_move_dest = move.end_position + dir
				var dest_piece = game_state.get_piece(double_move_dest)
				if dest_piece == null:
					var double_move = Move.new()
					double_move.start_position = move.start_position
					double_move.end_position = double_move_dest
					final_moves.append(double_move)
		
		#diagonal
		if dims == 2:
			var passant_piece = get_passant_piece(game_state, move.end_position)
			if passant_piece != null and passant_piece.piece_def.pawn: 
				move.pieces_to_take.append(passant_piece)
			if move.pieces_to_take.size() == 0: continue
		
		final_moves.append(move)
	return final_moves

## returns any piece that passed through the adjacaent vertical squares on preceding turn
func get_passant_piece(game_state: GameState, position) -> ChessPiece:
	var file_plus = Vector4i(0,0,0,1)
	var file_minus = Vector4i(0,0,0,-1)
	var time_minus = Vector4i(-1,0,0,0) 
	 
	var current_turn_forward = game_state.get_piece(position + file_plus)
	var current_turn_back = game_state.get_piece(position + file_minus)
	var last_turn_forward = game_state.get_piece(position + time_minus + file_plus)
	var last_turn_back = game_state.get_piece(position + time_minus + file_minus)
	if current_turn_back == null and last_turn_forward == null:
		if current_turn_forward is ChessPiece and last_turn_back is ChessPiece:
			return current_turn_forward
	if current_turn_forward == null and last_turn_back == null:
		if current_turn_back is ChessPiece and last_turn_forward is ChessPiece:
			return current_turn_back
	return
