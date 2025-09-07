class_name Board
extends Node

static var board_interval = 480
const time_plus = Vector2i(1,0)

var coord: Vector2i:
	set(val):
		coord = val
		recalculateBoardPosition()

var is_white: bool:
	get:
		return coord.x % 2 == 0

var chess_4d: Chess5d:
	get:
		return get_parent()

static var board_scene := preload("res://Scenes/board.tscn")
static var pawn := preload("res://Scenes/Pieces/pawn.tscn")
static var bishop := preload("res://Scenes/Pieces/bishop.tscn")
static var knight := preload("res://Scenes/Pieces/knight.tscn")
static var rook := preload("res://Scenes/Pieces/rook.tscn")
static var king := preload("res://Scenes/Pieces/king.tscn")
static var queen := preload("res://Scenes/Pieces/queen.tscn")
static var legalMoveHighlight  := preload("res://Scenes/legal_move_highlight.tscn")
static var conway_square := preload("res://Scenes/conway_square.tscn")

static func new_board(parent: Node, isWhite: bool = true):
	var instance = board_scene.instantiate()
	instance.createBaseBoard()
	parent.add_child(instance)
	return instance

func board_playable() -> bool:
	if is_white != chess_4d.is_white_turn:
		return false
	if chess_4d.get_board(coord + time_plus) != null:
		return false
	return true

func duplicate_board(coord) -> Node:
	#var instance = self.duplicate()
	#instance.coord = Vector2i(coord.x, coord.y)
	#return instance
	var instance = load("res://Scenes/board.tscn").instantiate()
	instance.coord = Vector2i(coord.x, coord.y)
	for piece in get_children():
		if piece.is_in_group("Piece"):
			instance.instance_piece(piece.resource, piece.coord, piece.is_white, piece.has_moved)
		if piece.is_in_group("blocks"):
			instance.place_conway(piece.coord)
	return instance


func move_piece(piece, coord: Vector4i):
	var stepSize = $BoardTexture.size / 8
	piece.full_coord = coord
	piece.position = Vector2i(stepSize.x * coord.z, stepSize.x * coord.w)
	piece.get_parent().remove_child(piece)
	piece.has_moved = true
	self.add_child(piece)

func place_highlight(place_coord: Vector2i):
	var stepSize = $BoardTexture.size / 8
	var instance = Globals.instanceSceneAtCoord(Vector2(stepSize.x * place_coord.x, stepSize.y * place_coord.y), self, legalMoveHighlight)
	instance.coord = Vector4i(coord.x, coord.y, place_coord.x, place_coord.y)
	return instance

func place_conway(place_coord: Vector2i):
	var stepSize = $BoardTexture.size / 8
	var instance = Globals.instanceSceneAtCoord(Vector2(stepSize.x * place_coord.x, stepSize.y * place_coord.y), self, conway_square)
	instance.full_coord = Vector4i(coord.x, coord.y, place_coord.x, place_coord.y)
	return instance

#func remove_piece(coord: Vector2i) -> void:
	#if board.has(coord):
		#var removed = board[coord]
		#board.erase(coord)
		#print("Removed ", removed, " from ", coord)
	#else:
		#print("No piece found at ", coord)

func recalculateBoardPosition():
	var vec =  Vector2i(coord.x * board_interval, coord.y * board_interval)
	self.position = vec
	$BoardOutline.color = Color.LIGHT_GRAY if is_white else Color.DIM_GRAY

func instance_piece(piece: PackedScene, placeCoord: Vector2i, isWhite: bool = true, has_moved: bool = false) -> void:
	var stepSize = $BoardTexture.size / 8
	var instance = Globals.instanceSceneAtCoord(Vector2(stepSize.x * placeCoord.x, stepSize.y * placeCoord.y), self, piece)
	instance.set_color(isWhite)
	instance.coord = Vector2i(placeCoord.x, placeCoord.y)
	instance.resource = piece
	instance.has_moved = has_moved

func createBaseBoard():
	# Place pawns
	for x in 8:
		instance_piece(pawn, Vector2i(x, 1), false) # White pawns
		instance_piece(pawn, Vector2i(x, 6)) # Black pawns

	# Place rooks
	instance_piece(rook, Vector2i(0, 0), false)
	instance_piece(rook, Vector2i(7, 0), false)
	instance_piece(rook, Vector2i(0, 7))
	instance_piece(rook, Vector2i(7, 7))

	# Place knights
	instance_piece(knight, Vector2i(1, 0), false)
	instance_piece(knight, Vector2i(6, 0), false)
	instance_piece(knight, Vector2i(1, 7))
	instance_piece(knight, Vector2i(6, 7))

	# Place bishops
	instance_piece(bishop, Vector2i(2, 0), false)
	instance_piece(bishop, Vector2i(5, 0), false)
	instance_piece(bishop, Vector2i(2, 7))
	instance_piece(bishop, Vector2i(5, 7))

	# Place queens
	instance_piece(queen, Vector2i(3, 0), false)
	instance_piece(queen, Vector2i(3, 7))

	# Place kings
	instance_piece(king, Vector2i(4, 0), false)
	instance_piece(king, Vector2i(4, 7))
	
	if ChessGame.singleton.conway_time:
		for x in range(3,5): for y in range(3,5):
			place_conway(Vector2i(x,y))
