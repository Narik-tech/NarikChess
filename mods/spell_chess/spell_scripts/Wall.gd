extends Spell

func _ready():
	super()
	spell_count_black = 1
	spell_count_white = 1

func spell_texture():
	return Mod.load_texture_from_png("wall.png")

func _attempt_spell(board: Board, coord: Vector2i):
	if board.is_white == chess_logic.is_white_turn:
		return false
	if board.get_piece(coord) != null:
		return false
	board.place_piece(WallPiece.inst(), coord)
	return true
