extends Spell

func spell_texture():
	return Mod.load_texture_from_png("freeze.png")

func _attempt_spell(board: Board, coord: Vector2i):
	#check validity
	if board.is_white == chess_logic.is_white_turn:
		return false
	
	#cast the spell
	var orig_coord = Vector4i(board.coord.x, board.coord.y, coord.x, coord.y)
	var alldirs := Globals.uniagonals + Globals.diagonals + Globals.triagonals + Globals.quadragonals
	alldirs.append(Vector4i.ZERO)
	for dir in alldirs:
		var dir_added = orig_coord + dir
		var target_board = chess_logic.get_board(dir_added)
		if target_board != null:
			target_board.place_piece(FreezePiece.inst(), dir_added)
		
	print_debug("Cast FREEZE")
	return true
