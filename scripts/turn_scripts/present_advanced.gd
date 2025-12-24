class_name PresentAdvanced
extends SubmitTurnCriteria

func can_submit_turn(board_game: BoardGame, turn_handling: TurnHandling) -> bool:
	if turn_handling.present.is_white == turn_handling.is_white_turn:
		return false
	return true
