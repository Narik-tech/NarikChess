## Piece that blocks movement and represents a Conway life cell.
class_name DuckPiece
extends Piece

static func inst() -> DuckPiece:
	var sq := Piece.square_scene.instantiate()
	sq.set_script(DuckPiece)
	sq.color = Color.YELLOW
	return sq
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
