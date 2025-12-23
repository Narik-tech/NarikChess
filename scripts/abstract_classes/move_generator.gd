@abstract
class_name MoveGenerator
extends Node

@abstract
func get_moves(game_state: GameState, start_pos: Vector4i, piece: ChessPiece) -> Array[Move]

##returns moves propagating pieces on their direction vectors, with captures for any pieces moved on
func simple_move_gen(game_state: GameState, start_pos: Vector4i, piece: ChessPiece) -> Array[Move]:
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

			move.start_position = start_pos
			move.end_position = squareToMove
			moves.append(move)
			
			if dest_piece: break
			
			if piece.piece_def.rider:
				squareToMove += dir	
				mag += 1
			else: 
				break
	return moves
