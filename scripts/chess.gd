class_name Chess
extends Node

### Piece Coords ###
#### (T,L,x,y)  ####

signal _on_starting_board_created(board: Board)
signal _on_move_made(piece: Piece, origin_board: Board, dest_board: Board)

static var chess_logic_scene := preload("res://scenes/chess_logic.tscn")
static var singleton : Chess

var chess_logic: ChessLogic
var selected_piece: Vector4i
var is_classic_chess: bool = false

func game_start():
	if chess_logic != null: chess_logic.queue_free()
	chess_logic = chess_logic_scene.instantiate()
	self.add_child(chess_logic)
	chess_logic.start_game()

func load_mods(mods: Array[Mod]):
	for mod in mods:
		self.add_child(mod)

func _ready():
	singleton = self
	game_start()

func _on_piece_selected(coord: Vector4i):
	selected_piece = coord
	chess_logic.show_legal_moves(selected_piece)


func _on_piece_destination_selected(coord: Vector4i):
	chess_logic.make_move(selected_piece, coord)

func _on_submit_pressed() -> void:
	chess_logic.submit_turn()

func _on_undo_pressed() -> void:
	chess_logic.undo()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
