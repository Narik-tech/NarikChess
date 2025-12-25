class_name CastlingMoveGen
extends MoveGenerator

func get_moves(game_state: GameState, start_pos, piece: ChessPiece) -> Array[Move]:
	if not piece.piece_def.royalty: return []
	if piece.has_moved: return []
	var moves: Array[Move] = []
	var orth = Globals.uniagonals
	for dir in orth:
		if game_state.classic_chess:
			if dir.x != 0 or dir.y != 0:
				continue
		var squareToMove = dir + start_pos
		while(game_state.coord_valid(squareToMove)):
			var dest_piece = game_state.get_piece(squareToMove, 0)
			if dest_piece != null:
				if dest_piece.piece_def == piece.rook and dest_piece.has_moved == false:
					var move = Move.new()
					move.start_position = start_pos
					move.end_position = start_pos + (dir * 2)
					move.post_move_callable = castle_rook.bind(game_state, squareToMove, start_pos + dir)
					moves.append(move)
				break
			squareToMove += dir
		
	return moves

func castle_rook(game_state: GameState, start_position: Vector4i, end_pos: Vector4i):
	var time_plus = Vector4i(1,0,0,0)
	start_position += time_plus
	end_pos += time_plus
	var copy = game_state.get_piece(start_position, 0).duplicate(7)
	game_state.remove_piece(start_position)
	game_state.place_piece(copy, end_pos)
	
	
