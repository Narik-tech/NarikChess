class_name MultiverseMoveGen
extends MoveGenerator

func get_moves(game_state: GameState, start_pos: Vector4i, piece: Piece) -> Array[Move]:
	if piece is not ChessPiece: return []
	var moves: Array[Move] = []
	for dir in piece.get_direction_vectors():
		var squareToMove = dir + start_pos
		var dims = Globals.dims_count(dir)
		var mag = 1
		while(game_state.coord_valid(squareToMove)):
			var move = Move.new()
			var dest_piece = game_state.get_piece(squareToMove)
			if dest_piece != null:
				if dest_piece.blocks_movement(piece):
					break
				move.pieces_to_take.append(dest_piece)
				
			if piece.piece_def.pawn:
				if dims == 1 and dest_piece != null: break
				if dims == 2 and (dest_piece == null or dest_piece.is_overlay): break
#			
			move.start_position = start_pos
			move.end_position = squareToMove
			moves.append(move)
			
			if dest_piece: break
			
			if piece.piece_def.rider or (piece.piece_def.pawn and !piece.has_moved and mag == 1):
				squareToMove += dir	
				mag += 1
			else: 
				break
	return moves
