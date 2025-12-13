class_name FreezePiece
extends Piece

static var _freeze_color: Color = Color(0.169, 0.431, 0.478, 0.62)

static func inst() -> Piece:
	return Piece.color_inst(_freeze_color, FreezePiece)

func _ready():
	is_overlay = true
