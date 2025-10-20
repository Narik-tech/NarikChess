class_name ChessGame
extends Node

### Piece Coords ###
#### (T,L,x,y)  ####

static var chess_logic := preload("res://scenes/chess_logic.tscn")

static var singleton : ChessGame
var chess_client: ChessLogic
var selected_piece: Vector4i

func game_start():
	if chess_client != null: chess_client.queue_free()
	chess_client = chess_logic.instantiate()
	self.add_child(chess_client)
	chess_client.start_game()

func _ready():
	singleton = self
	game_start()

func _on_piece_selected(coord: Vector4i):
	selected_piece = coord
	chess_client.show_legal_moves(selected_piece)


func _on_piece_destination_selected(coord: Vector4i):
	chess_client.make_move(selected_piece, coord)


func _on_submit_pressed() -> void:
	chess_client.submit_turn()


func _on_undo_pressed() -> void:
	chess_client.undo()


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
