## Piece that blocks movement and represents a Conway life cell.
class_name ConwaySquare
extends Piece

static func inst() -> ConwaySquare:
	return Piece.color_inst(Color.FOREST_GREEN, ConwaySquare)
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
 
