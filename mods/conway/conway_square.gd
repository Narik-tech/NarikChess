## Piece that blocks movement and represents a Conway life cell.
class_name ConwaySquare
extends Piece

static func inst() -> ConwaySquare:
	var sq := Piece.square_scene.instantiate()
	sq.set_script(ConwaySquare)   # uses this script
	sq.color = Color.FOREST_GREEN
	return sq
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
