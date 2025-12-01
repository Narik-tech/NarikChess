## Overlay node that marks legal destinations and emits selection events.
class_name MoveHighlight
extends Piece

signal selected(coord: Vector4i)

static func inst() -> MoveHighlight:
	var highlight = Piece.color_inst(Color("#ff74ff92"), MoveHighlight)
	highlight.selected.connect(Chess.singleton._on_piece_destination_selected)
	return highlight

func piece_ready():
	is_overlay = true
	add_to_group("Highlight")

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(full_coord)
