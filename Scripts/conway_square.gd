class_name ConwaySquare
extends Sprite2D

var board: Board:
	get:
		return get_parent()
var coord: Vector2i
var full_coord: Vector4i:
	get:
		var p = get_parent()
		return Vector4i(p.coord.x,p.coord.y,coord.x,coord.y)
	set(val):
		coord.x = val.z
		coord.y = val.w

#static var pixelDistance = 8
static var Block = preload("res://Scenes/conway_square.tscn")
static var blockDict = {}
static var pieceDict = {}
#static var tempPlayerBlocks = {}
#static var maxPlayerBlocks = 5

static func instanceAll():
	for coord in blockDict.keys():
		if not coord_valid(coord): continue
		blockDict[coord] += pieceDict[coord] if pieceDict.has(coord) else 0
		if(blockDict[coord] == 3):
			instanceBlock(coord)

static func coord_valid(piece_vec: Vector4i) -> bool:
	return not (piece_vec.z < 0 or piece_vec.z > 7 or piece_vec.w < 0 or piece_vec.w > 7)

#static func instancePlayerBlock(coord):
	#if tempPlayerBlocks.has(coord) || tempPlayerBlocks.size() >= maxPlayerBlocks: return
	#tempPlayerBlocks[coord] = instanceBlock(coord)
#
#static func removePlayerBlock(coord):
	#if !tempPlayerBlocks.has(coord): return
	#var instance = tempPlayerBlocks[coord]
	#instance.queue_free()
	#tempPlayerBlocks.erase(coord)

static func instanceBlock(coord):
	assert(coord is Vector4i)
	var board = ChessGame.singleton.chess_client.get_board(coord)
	board.place_conway(Vector2i(coord.z, coord.w))

static func reset():
	blockDict.clear()
	#tempPlayerBlocks.clear()

func preTick():
	blockDict[self.full_coord] = -1
	pieceDict[self.full_coord] = -1
	for pos in getNearby():
		if(blockDict.has(pos)):
			if(blockDict[pos] == -1): continue
			blockDict[pos] += 1
		else:
			blockDict[pos] = 1

func tick():
	var dict = blockDict
	var blocks = getNearbyBlocks()
	if blocks.size() != 2 and blocks.size() != 3:
		self.queue_free()

func getNearbyBlocks():
	return getNearby().filter(func(x): return blockDict[x] == -1)

func getNearby():
	var out: Array = []
	for z in range(-1,2,1): for w in range(-1,2,1):
			if(z==0 && w==0): continue
			out.append(Vector4i(board.coord.x,board.coord.y,z,w) + Vector4i(0,0,coord.x,coord.y))
	return out
