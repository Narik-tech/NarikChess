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
	move_handling.space_selected(position, piece)
	
func undo():
	game_state.undo_move()

func add_ui_element(control: Control):
	mod_ui_container.add_child(control)

func display_message(text: String):
	info_display.text = text

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
