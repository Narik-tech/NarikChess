extends Mod

#Before playing a move, require the player to place a duck on the board if it has no duck
func _can_play_move(origin: Vector4i, dest: Vector4i):
	return true

#Only allow turn submission if the duck on each board is at a different location to the preceding board
func _can_submit_turn():
	return true
