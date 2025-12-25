class_name Spell
extends Node

var spell_count_white := 3
var spell_count_black := 3

signal _on_spell_cast()
signal _on_spell_undo()

var texture: CompressedTexture2D
var spell_button: TextureButton
var spell_chess: Mod
var game_state: GameState:
	get: return spell_chess.game_state

func _ready():
	var texture2d = spell_texture()
	if texture2d == null:
		push_error("No texture returned from spell_texture in " + name)
	spell_button.texture_normal = texture2d

func spell_texture() -> CompressedTexture2D:
	return load("res://sprites/twobytwo.png")

func valid_spell_turn():
	return spell_button.button_pressed

func on_space_selected(_position: Vector4i, _piece: Control):
	if spell_chess.board_game.turn_handling.is_white_turn:
		if valid_spell_turn() and spell_count_white > 0 and not spell_chess.spell_used_this_turn:
			if spell_chess.board_game.move_handling.make_move(_attempt_spell.bind(_position, _piece), _undo_spell.bind(true)):
				spell_count_white -= 1
				_on_spell_cast.emit()
	else:
		if valid_spell_turn() and spell_count_black > 0 and not spell_chess.spell_used_this_turn:
			if spell_chess.board_game.move_handling.make_move(_attempt_spell.bind(_position, _piece), _undo_spell.bind(false)):
				spell_count_black -= 1
				_on_spell_cast.emit()

func _undo_spell(is_white: bool):
	spell_chess.spell_used_this_turn = false
	if is_white:
		spell_count_white += 1
	else:
		spell_count_black += 1
	_on_spell_undo.emit()

## returns true if spell was used
func _attempt_spell(_position: Vector4i, _piece: Control) -> bool:
	push_error("must define _attempt_spell function in Spell " + name)
	return false
