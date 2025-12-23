class_name TurnHandling
extends Node

@export var present: Present

signal turn_changed(white_turn: bool)

var is_white_turn: bool = true:
	set(val):
		is_white_turn = val
		turn_changed.emit(is_white_turn)

func _on_submit_pressed():
	if present.is_white == is_white_turn:
		return false
	
	is_white_turn = !is_white_turn
	return true
