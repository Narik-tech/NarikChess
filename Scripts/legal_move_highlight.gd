extends ColorRect

signal dest_selected(coord: Vector4i)

var coord: Vector4i

func _ready():
	dest_selected.connect(ChessGame.singleton._on_piece_destination_selected)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		dest_selected.emit(coord)
