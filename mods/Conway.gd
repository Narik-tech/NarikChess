## Summary: Mod that seeds Conway squares and advances their lifecycle after each move.
extends Mod

## add conway squares to center
func _on_starting_board(board: Board):
	for x in range(3,5): for y in range(3,5):
		board.place_piece(ConwaySquare.inst(), Vector2i(x,y))

## progress game of life on any created boards
func _on_move_made(_piece: Piece, _origin_board: Board, _dest_board: Board):
	progress_squares(_origin_board)
	if _dest_board != _origin_board:
		progress_squares(_dest_board)

func progress_squares(board: Board):
	#determine all piece locations on board
	var piece_dict : Dictionary[Vector4i, Piece] = {}
	for piece in board.get_children().filter(func(x): return x is Piece and x.is_overlay == false):
		piece_dict[piece.full_coord] = piece
	
	#determine conway progression for each case
	for z in 7: for w in 7:
		var piece_coord = Vector4i(board.coord.x,board.coord.y,z,w)
		var piece = piece_dict.get(piece_coord)
		if piece is ConwaySquare:
			var nearby = get_nearby(piece_coord, piece_dict)
			if nearby.size() != 2 and nearby.size() != 3:
				piece.queue_free()
		if piece == null:
			var nearby = get_nearby(piece_coord, piece_dict)
			var has_conway := nearby.any(func(x): return x is ConwaySquare)
			if has_conway and nearby.size() == 3:
				board.place_piece(ConwaySquare.inst(), Vector2i(z,w))

func get_nearby(full_coord: Vector4i, piece_dict: Dictionary[Vector4i, Piece]) -> Array:
	var out: Array = []
	for z in range(-1,2,1): for w in range(-1,2,1):
			if(z==0 && w==0): continue
			var piece = piece_dict.get(full_coord + Vector4i(0,0,z,w))
			if piece != null: out.append(piece)
	return out
