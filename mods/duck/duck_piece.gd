## Piece that blocks movement and represents a Conway life cell.
class_name DuckPiece
extends Piece

static func inst() -> DuckPiece:
	return Piece.texture_inst(Mod.load_texture_from_png("duck.png"), DuckPiece)
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
