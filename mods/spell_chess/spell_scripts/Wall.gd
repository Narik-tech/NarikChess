extends Spell

func _ready():
	super()
	spell_count_black = 1
	spell_count_white = 1

func spell_texture():
	return Mod.load_texture_from_png("wall.png")

func _attempt_spell(_position: Vector4i, _piece: Control):
	var board = game_state.get_board(Vector2i(_position.x, _position.y))
	if board.is_white == spell_chess.board_game.turn_handling.is_white_turn:
		return false
	if board.get_piece(_position) != null:
		return false
	board.place_piece(WallPiece.inst(), _position)
	return true
