class_name WallPiece
extends Piece

static var _wall_color: Color = Color(0.616, 0.365, 0.176, 1.0)

static func inst() -> Piece:
	return Piece.color_inst(_wall_color, WallPiece)

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
