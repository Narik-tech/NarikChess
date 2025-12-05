class_name Spell
extends Mod

var texture: CompressedTexture2D
var spell_button: TextureButton
var spell_chess: Mod

func _ready():
	spell_button.texture_normal = spell_texture()

func spell_texture() -> CompressedTexture2D:
	return load("res://sprites/twobytwo.png")

func valid_spell_turn():
	return spell_button.button_pressed

func on_any_select(_board: Board, _coord: Vector2i):
	if valid_spell_turn():
		_attempt_spell(_board, _coord)

## returns true if spell was used
func _attempt_spell(board: Board, coord: Vector2i) -> bool:
	push_error("must define _attempt_spell function in Spell " + name)
	return false
