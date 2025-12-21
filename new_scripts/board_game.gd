class_name BoardGame
extends Node

@export var game_state: GameState
@export var move_handling: MoveHandling
@export var move_legality: MoveLegality
@export var turn_handling: TurnHandling
@export var board_init: BoardInitializer

@export var info_display: RichTextLabel 
@export var mod_ui_container: HFlowContainer
 

func _ready():
	game_start()

func game_start():
	board_init.create_starting_boardset(game_state)

func on_space_selected(position: Vector4i, piece: Piece):
	print_debug(position, piece)
	move_handling.space_selected(position, piece)
	
func undo():
	game_state.undo()
 
#func _on_submit_pressed() -> void:
	#if present.is_white == is_white_turn:
		#return false
	#
	#move_stack.clear()
	#is_white_turn = !is_white_turn
	#return true
