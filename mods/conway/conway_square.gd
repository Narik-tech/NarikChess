## Piece that blocks movement and represents a Conway life cell.
class_name ConwaySquare
extends Piece
@export var conway_texture: Texture2D

static func inst() -> ConwaySquare:
	return Piece.texture_inst(Mod.load_texture_from_png("conway_piece.png"), ConwaySquare)
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
 
