##Restricts board and piece selection to current players turn
class_name CurrentTurnCriteria
extends PieceSelectableCriteria

func is_white_board(position: Vector4i) -> bool:
	return position.x % 2 == 0

func can_select_piece(board_game: BoardGame, position, piece: Piece) -> bool:
	if piece is not ChessPiece: return true
	if board_game.turn_handling.is_white_turn != is_white_board(position):
		return false
	if (piece as ChessPiece).is_white != board_game.turn_handling.is_white_turn:
		return false
	return true
