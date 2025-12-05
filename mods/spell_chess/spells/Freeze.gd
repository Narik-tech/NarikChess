extends Spell

func spell_texture():
	return load("res://mods/spell_chess/freeze.png")

func _attempt_spell(board: Board, coord: Vector2i):
	print_debug("Cast FREEZE")
	return true
