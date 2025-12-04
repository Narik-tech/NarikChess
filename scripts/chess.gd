## Central game node that spawns logic, handles selection inputs, and relays UI actions for a match session.
class_name Chess
extends Node

### Piece Coords ###
#### (T,L,x,y)  ####

@export var info_display: RichTextLabel 
@export var mod_ui_container: HFlowContainer

@warning_ignore("unused_signal")
signal _on_starting_board_created(board: Board)
@warning_ignore("unused_signal")
signal _on_move_made(piece: Vector4i, origin_board: Board, dest_board: Board)
@warning_ignore("unused_signal")
signal _on_empty_space_selected(board: Board, coord: Vector2i)

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
	
func get_mods() -> Array[Mod]:
	var mods: Array[Mod] = []
	for c in get_children():
		if c is Mod:
			mods.append(c)
	return mods

func mods_allow_play_move(from: Vector4i, to) -> bool:
	for mod: Mod in get_mods():
		var ok = mod._can_play_move(from, to)
		if ok is String:
			display_message(ok)
			return false
	return true

func mods_allow_submit_turn() -> bool:
	for mod: Mod in get_mods():
		var ok = mod._can_submit_turn()
		if ok is String:
			display_message(ok)
			return false
	return true

func add_mod_ui(control: Control):
	mod_ui_container.add_child(control)

func display_message(text: String):
	info_display.text = text

func _ready():
	singleton = self
	game_start()

func _on_piece_selected(coord: Vector4i):
	if not mods_allow_play_move(selected_piece, coord): return
	selected_piece = coord
	chess_logic.show_legal_moves(selected_piece)

func _on_piece_destination_selected(coord: Vector4i):
	if not mods_allow_play_move(selected_piece, coord): return
	chess_logic.make_move(selected_piece, coord)

func _on_submit_pressed() -> void:
	if not mods_allow_submit_turn(): return
	chess_logic.submit_turn()

func _on_undo_pressed() -> void:
	chess_logic.undo()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
