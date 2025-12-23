class_name Spell
extends Node

var spell_count_white := 3
var spell_count_black := 3

signal _on_spell_cast()

var texture: CompressedTexture2D
var spell_button: TextureButton
var spell_chess: Mod
var game_state: GameState:
	get: return spell_chess.chess_logic

func _ready():
	var texture2d = spell_texture()
	if texture2d == null:
		push_error("No texture returned from spell_texture in " + name)
	spell_button.texture_normal = texture2d

func spell_texture() -> CompressedTexture2D:
	return load("res://sprites/twobytwo.png")

func valid_spell_turn():
	return spell_button.button_pressed

func on_any_select(_board: Board, _coord: Vector2i):
	if game_state.is_white_turn:
		if game_state.is_white_turn and valid_spell_turn() and spell_count_white > 0 and not spell_chess.spell_used_this_turn:
			if _attempt_spell(_board, _coord):
				# spell casted
				spell_count_white -= 1
				_on_spell_cast.emit()
	else:
		if valid_spell_turn() and spell_count_black > 0 and not spell_chess.spell_used_this_turn:
			if _attempt_spell(_board, _coord):
				# spell casted
				spell_count_black -= 1
				_on_spell_cast.emit()

## returns true if spell was used
@warning_ignore("unused_parameter")
func _attempt_spell(board: Board, coord: Vector2i) -> bool:
	push_error("must define _attempt_spell function in Spell " + name)
	return false
