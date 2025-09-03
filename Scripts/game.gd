class_name game
extends Node

static var board := preload("res://Scenes/board.tscn")
static var Singleton

const boardInterval = 440

var highlightedPiece
var highlightedCoord: Vector4i
var HighlightedSquares = []

var isWhiteTurn: bool = true

var whiteBoardDict: Dictionary[Vector2i, Node2D] = {}
var blackBoardDict: Dictionary[Vector2i, Node2D] = {}

var whiteTimelines := 0
var blackTimelines := 0

func _ready() -> void:
	Singleton = self
	createStartingBoard()

func createStartingBoard():
	addBoardAtCoord(Vector2i.ZERO, true)

func copyBoardAtCoord(coord: Vector2i, orig: Node, isWhite: bool):
	clearHighlights()
	var dict = whiteBoardDict if isWhite else blackBoardDict
	var instance = orig.duplicateBoard(coord)
	instance.position = calculateBoardPosition(coord)
	instance.coord = coord
	instance.setPieceCoords(coord)
	instance.isWhiteBoard = isWhite
	instance.setBoardColor()
	dict[coord] = instance
	self.add_child(instance)
	clearHighlights()
	
	var boardDict = instance.board
	
	return instance

func calculateBoardPosition(coord: Vector2i):
	return Vector2i(coord.x * boardInterval * 2 + (boardInterval if isWhiteTurn else 0), coord.y * boardInterval)

func addBoardAtCoord(coord: Vector2i, isWhiteTurn: bool):
	var dict = whiteBoardDict if isWhiteTurn else blackBoardDict
	assert(!dict.has(coord))
	var instance = Globals.instanceSceneAtCoord(coord, self, board)
	instance.coord = coord
	instance.isWhiteBoard = isWhiteTurn
	instance.setBoardColor()
	instance.createBaseBoard()
	dict[coord] = instance
	

func showLegalMoves(piece: Node, pieceCoord: Vector4i, dirs: Array[Vector4i], isPawn: bool, isRider: bool):
	clearHighlights()
	highlightedPiece = piece
	highlightedCoord = pieceCoord
	for dir in dirs:
		var squareToMove = dir + pieceCoord
		while(coordValid(squareToMove)):
			highlightLegalMove(squareToMove)
			squareToMove += dir

func coordValid(pieceCoord: Vector4i) -> bool:
	if pieceCoord.z < 0 || pieceCoord.z > 7 || pieceCoord.w < 0 || pieceCoord.w > 7:
		return false
	if getBoardFromCoord(pieceCoord, isWhiteTurn) == null:
		return false
	return true

func highlightLegalMove(coord: Vector4i):
	HighlightedSquares.append(getBoardFromCoord(coord, isWhiteTurn).place_highlight(Vector2i(coord.z,coord.w)))

func MovePieceToCoord(coordToPlace: Vector4i):
	var origBoard = getBoardFromCoord(highlightedCoord, isWhiteTurn)
	clearHighlights()
	assert(origBoard != null)
	
	#handle moves on boards that advance this lines boardstate
	if(highlightedCoord.x == coordToPlace.x && highlightedCoord.y == coordToPlace.y):
		var instance = copyBoardAtCoord(Vector2i(coordToPlace.x + (0 if isWhiteTurn else 1), coordToPlace.y), origBoard, !origBoard.isWhiteBoard)
		instance.movePiece(instance.board[Vector2i(highlightedPiece.coord.z, highlightedPiece.coord.w)], coordToPlace)
		instance.remove_piece(Vector2i(highlightedCoord.z,highlightedCoord.w))
	#handle travel moves
	else:
		var newtimelineY
		if isWhiteTurn:
			whiteTimelines += 1
			newtimelineY = whiteTimelines
		else:
			blackTimelines -= 1
			newtimelineY = blackTimelines
		var forwardInstance = copyBoardAtCoord(Vector2i(coordToPlace.x + (0 if isWhiteTurn else 1), coordToPlace.y), origBoard, !origBoard.isWhiteBoard)
		var travelInstance = copyBoardAtCoord(Vector2i(coordToPlace.x + (0 if isWhiteTurn else 1), newtimelineY), origBoard, !origBoard.isWhiteBoard)
		travelInstance.movePiece(travelInstance.board[Vector2i(highlightedPiece.coord.z, highlightedPiece.coord.w)], coordToPlace)
		travelInstance.remove_piece(Vector2i(highlightedCoord.z,highlightedCoord.w))
		pass
		
	#getBoardFromCoord(highlightedCoord, isWhiteTurn).remove_piece(Vector2i(highlightedCoord.z,highlightedCoord.w))
	isWhiteTurn = !isWhiteTurn

func getNextBoard(board):
	if board.isWhiteBoard:
		getBoardFromCoord(board.coord, false)
	else:
		getBoardFromCoord(board.coord + Vector2i(1, 0), true)

func clearHighlights():
	for square in get_tree().get_nodes_in_group("Highlight"):
		square.queue_free()
	#HighlightedSquares.clear()

func getBoardFromCoord(coord, isWhite: bool):
	var dict = whiteBoardDict if isWhiteTurn else blackBoardDict
	return dict.get(Vector2i(coord.x, coord.y))
	
func getPieceFromCoord(coord: Vector4i) -> Node:
	var board = getBoardFromCoord(coord, isWhiteTurn)
	if board == null: return null
	return board.board.get(Vector2i(coord.z, coord.w))
