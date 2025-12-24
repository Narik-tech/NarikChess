class_name TurnHandling
extends Node

@export var present: Present
@export var board_game: BoardGame

signal turn_changed(white_turn: bool)

var _submit_turn_criteria: Array[SubmitTurnCriteria]

func _ready():
	_submit_turn_criteria.append(PresentAdvanced.new())

var is_white_turn: bool = true:
	set(val):
		is_white_turn = val
		turn_changed.emit(is_white_turn)

func _on_submit_pressed() -> bool:
	for criteria in _submit_turn_criteria:
		if not criteria.can_submit_turn(board_game, self): return false
	
	is_white_turn = !is_white_turn
	return true
