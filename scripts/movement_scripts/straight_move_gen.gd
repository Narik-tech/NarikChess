##Generates legal moves for simple chess pieces moving in straight lines, taking any pieces they land on 
class_name StraightMoveGen
extends MoveGenerator

func get_moves(game_state: GameState, start_pos, piece: ChessPiece) -> Array[Move]:
	if piece.piece_def.pawn: return []
	return simple_move_gen(game_state, start_pos, piece)
