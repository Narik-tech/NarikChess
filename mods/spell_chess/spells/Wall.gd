extends Spell

func spell_texture():
	return load("res://mods/spell_chess/wall.png")

func _attempt_spell(board: Board, coord: Vector2i):
	print_debug("Cast WALL")
	return true
