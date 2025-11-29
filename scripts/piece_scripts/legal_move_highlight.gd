## Overlay node that marks legal destinations and emits selection events.
class_name MoveHighlight
extends Piece

signal dest_selected(coord: Vector4i)
static var move_highlight := preload("res://scenes/pieces/legal_move_highlight.tscn")

static func inst() -> MoveHighlight:
	return move_highlight.instantiate()

func _ready():
	is_overlay = true
	dest_selected.connect(Chess.singleton._on_piece_destination_selected)

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		dest_selected.emit(full_coord)
