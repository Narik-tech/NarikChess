## Piece that blocks movement and represents a Conway life cell.
class_name DuckPiece
extends Piece

static var duck_texture: Texture2D = preload("res://mods/duck/duck.png")

static func inst() -> DuckPiece:
	return Piece.texture_inst(duck_texture, DuckPiece)
	
func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
