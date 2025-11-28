class_name ConwaySquare
extends Piece

static var conway_square_script := preload("res://mods/mod_pieces/conway_square.gd")

static func inst() -> ConwaySquare:
	var conway_square = Piece.square_scene.instantiate()
	conway_square.set_script(conway_square_script)
	conway_square.color = Color.FOREST_GREEN
	return conway_square

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	return true
