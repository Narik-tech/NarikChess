extends Node

# Dictionary to store the board state: key = coord, value = piece
var board: Dictionary[Vector2i, Node] = {}
var isWhiteBoard : bool = true
var coord: Vector2i 

static var pawn := preload("res://Scenes/Pieces/pawn.tscn")
static var bishop := preload("res://Scenes/Pieces/bishop.tscn")
static var knight := preload("res://Scenes/Pieces/knight.tscn")
static var rook := preload("res://Scenes/Pieces/rook.tscn")
static var king := preload("res://Scenes/Pieces/king.tscn")
static var queen := preload("res://Scenes/Pieces/queen.tscn")

static var legalMoveHighlight  := preload("res://Scenes/legal_move_highlight.tscn")

func setBoardColor():
    $BoardOutline.color = Color.LIGHT_GRAY if isWhiteBoard else Color.DIM_GRAY

func setPieceCoords(coord: Vector2i):
    pass
    #for key in board:
        #board[key].coord.x = coord.x
        #board[key].coord.y = coord.y

func duplicateBoard(coord: Vector2i) -> Node:
    var instance = load("res://Scenes/board.tscn").instantiate()
    instance.coord = coord
    for key in board:
        print(instance.board.size())
        var piece = board[key]
        instance.place_piece(piece.resource, key, piece.isWhite)
    return instance
        
func createBaseBoard():
    # Place pawns
    for x in 8:
        place_piece(pawn, Vector2i(x, 1), false) # White pawns
        place_piece(pawn, Vector2i(x, 6)) # Black pawns

    # Place rooks
    place_piece(rook, Vector2i(0, 0), false)
    place_piece(rook, Vector2i(7, 0), false)
    place_piece(rook, Vector2i(0, 7))
    place_piece(rook, Vector2i(7, 7))

    # Place knights
    place_piece(knight, Vector2i(1, 0), false)
    place_piece(knight, Vector2i(6, 0), false)
    place_piece(knight, Vector2i(1, 7))
    place_piece(knight, Vector2i(6, 7))

    # Place bishops
    place_piece(bishop, Vector2i(2, 0), false)
    place_piece(bishop, Vector2i(5, 0), false)
    place_piece(bishop, Vector2i(2, 7))
    place_piece(bishop, Vector2i(5, 7))

    # Place queens
    place_piece(queen, Vector2i(3, 0), false)
    place_piece(queen, Vector2i(3, 7))

    # Place kings
    place_piece(king, Vector2i(4, 0), false)
    place_piece(king, Vector2i(4, 7))

# Place a piece at a given coordinate
func place_piece(piece: PackedScene, placeCoord: Vector2i, isWhite: bool = true) -> void:
    var stepSize = $BoardTexture.size / 8
    #if board.has(coord):
        #print("There’s already a piece at ", coord, ". Replacing it.")
    var instance = Globals.instanceSceneAtCoord(Vector2(stepSize.x * placeCoord.x, stepSize.y * placeCoord.y), self, piece)
    instance.SetColor(isWhite)
    instance.coord = Vector4i(coord.x, coord.y, placeCoord.x, placeCoord.y)
    instance.resource = piece
    board[placeCoord] = instance

func movePiece(piece, coord: Vector4i):
    var stepSize = $BoardTexture.size / 8
    piece.coord = coord
    board[Vector2i(coord.z, coord.w)] = piece
    piece.position = Vector2i(stepSize.x * coord.z, stepSize.x * coord.w)
    piece.get_parent().remove_child(piece)
    self.add_child(piece)

func place_highlight(placeCoord: Vector2i):
    var stepSize = $BoardTexture.size / 8
    var instance = Globals.instanceSceneAtCoord(Vector2(stepSize.x * placeCoord.x, stepSize.y * placeCoord.y), self, legalMoveHighlight)
    instance.coord = Vector4i(coord.x, coord.y, placeCoord.x, placeCoord.y)
    return instance
    
# Remove a piece from a given coordinate
func remove_piece(coord: Vector2i) -> void:
    if board.has(coord):
        var removed = board[coord]
        board.erase(coord)
        #print("Removed ", removed, " from ", coord)
    #else:
        #print("No piece found at ", coord)

# Helper to see what piece is at a coord
func get_piece(coord: Vector2) -> String:
    return board.get(coord, "")
