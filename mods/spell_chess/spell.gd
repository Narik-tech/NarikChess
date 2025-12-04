class_name Spell
extends Node

var texture: CompressedTexture2D

func spell_texture() -> CompressedTexture2D:
	return load("res://sprites/twobytwo.png")

## returns true if spell was used
func _attempt_spell(board: Board, coord: Vector2i) -> bool:
	push_error("must define _attempt_spell function in Spell " + name)
	return false

func spell_selected():
	_on_spell_selected()

func _on_spell_selected():
	pass

func _on_spell_deselected():
	pass
