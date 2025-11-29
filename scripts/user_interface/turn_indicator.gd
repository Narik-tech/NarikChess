## Summary: Label that updates text and color to reflect whose turn it is.
extends RichTextLabel

func _on_turn_changed(white_turn: bool) -> void:
	text = ("White" if white_turn else "Black") + " Turn"
	modulate = Color.WHITE if white_turn else Color.BLACK
