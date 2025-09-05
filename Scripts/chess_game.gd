class_name ChessGame
extends Node

### Piece Coords ###
#### (T,L,x,y)  ####

static var singleton : ChessGame
var chess_client
var selected_piece: Vector4i
var isWhiteTurn

func _ready():
	singleton = self
	chess_client = $"5DChess"
	chess_client.start_game()


func _on_piece_selected(coord: Vector4i):
	selected_piece = coord
	chess_client.show_legal_moves(selected_piece)


func _on_piece_destination_selected(coord: Vector4i):
	chess_client.make_move(selected_piece, coord)
