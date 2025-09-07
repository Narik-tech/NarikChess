extends RichTextLabel

func _on_turn_changed(white_turn: bool) -> void:
	text = ("White" if white_turn else "Black") + " Turn"
	modulate = Color.WHITE if white_turn else Color.BLACK
