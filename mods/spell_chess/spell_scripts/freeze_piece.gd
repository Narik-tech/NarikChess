class_name FreezePiece
extends Piece

static var _freeze_color: Color = Color(0.169, 0.431, 0.478, 0.62)

static func inst() -> Piece:
	var instance = Piece.color_inst(_freeze_color, FreezePiece)
	instance.is_overlay = true
	return instance
