class_name BoardInitializer
extends Node

@export var starting_boardset: BoardSet

func create_starting_boardset(game_state: GameState):
	for board in starting_boardset.boards:
		game_state.place_board(Board.inst(game_state), board.pos)
		place_from_fen(game_state, board.pos, board.fen)

func place_from_fen(game_state: GameState, board_coord: Vector2i, fen: String) -> void:
	var placement := fen.split(" ", false)[0]
	var ranks := placement.split("/", false)
	assert(ranks.size() == 8)

	for fen_rank in range(8): # FEN ranks 8 → 1
		var y := 7 - fen_rank
		var x := 0

		for ch in ranks[fen_rank]:
			# Empty squares
			if ch.is_valid_int():
				x += int(ch)
				continue

			var is_white :bool = ch >= "A" and ch <= "Z"
			var piece_type: ChessPieceDef
			match ch.to_lower():
				"p": piece_type = ChessPiece.pawn
				"n": piece_type = ChessPiece.knight
				"b": piece_type = ChessPiece.bishop
				"r": piece_type = ChessPiece.rook
				"q": piece_type = ChessPiece.queen
				"k": piece_type = ChessPiece.king
				_: null

			if piece_type == null:
				push_error("Invalid FEN piece: %s" % ch)
				return
			
			var board = game_state.get_board(board_coord)
			var flipped_y = board.piece_grid.flip_y(Vector2i(x,y))
			game_state.place_piece(
				ChessPiece.inst(piece_type, is_white),
				Vector4i(board_coord.x, board_coord.y,flipped_y.x,flipped_y.y)
			)
			x += 1
