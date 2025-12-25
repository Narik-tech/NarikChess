## Overlay node that marks legal destinations and emits selection events.
class_name MoveHighlight
extends Piece

var highlight_action: Callable

static func inst(callback: Callable) -> MoveHighlight:
	var highlight = Piece.color_inst(Color("#ff74ff92"), MoveHighlight)
	highlight.highlight_action = callback
	highlight.add_to_group("MoveHighlight")
	highlight.is_overlay = true
	return highlight

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return false
