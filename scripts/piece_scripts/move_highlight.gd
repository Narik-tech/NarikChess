## Overlay node that marks legal destinations and emits selection events.
class_name MoveHighlight
extends Piece

static func inst(callback: Callable) -> MoveHighlight:
	var highlight = Piece.color_inst(Color("#ff74ff92"), MoveHighlight)
	highlight._on_piece_clicked.connect(callback)
	highlight.add_to_group("MoveHighlight")
	return highlight

func piece_ready():
	is_overlay = true

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return false
