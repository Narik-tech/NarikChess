extends Spell

func spell_texture():
	return Mod.load_texture_from_png("freeze.png")

func _attempt_spell(_position: Vector4i, _piece: Control):
	#check validity
	if (_position.x % 2 == 0) == spell_chess.board_game.turn_handling.is_white_turn:
		return false
	
	#cast the spell
	var alldirs := Globals.uniagonals + Globals.diagonals + Globals.triagonals + Globals.quadragonals
	alldirs.append(Vector4i.ZERO)
	for dir in alldirs:
		var dir_added = _position + dir
		var target_piece = game_state.get_piece(dir_added)
		if target_piece != null:
			game_state.place_piece(FreezePiece.inst(), dir_added, 1)
		
	print_debug("Cast FREEZE")
	return true
