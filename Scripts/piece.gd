class_name piece
extends TextureRect

var resource: PackedScene

@export_flags("Uniagonal", "Diagonal", "Triagonal","Quadragonal", "L") var directions = 0
@export_flags("Pawn", "Rider") var specialFlags = 0

var isWhite: bool = true
var coord: Vector4i

var Uniagonal: 
	get: return 1 & directions != 0
var Diagonal: 
	get: return 2 & directions != 0
var Triagonal: 
	get: return 4 & directions != 0
var Quadragonal: 
	get: return 8 & directions != 0
var L: 
	get: return 16 & directions != 0
var Pawn: 
	get: return 1 & specialFlags != 0
var Rider: 
	get: return 2 & specialFlags != 0

#(T,L,x,y)
static var uniagonals: Array[Vector4i] = [Vector4i(1,0,0,0), Vector4i(0,1,0,0), Vector4i(0,0,1,0), Vector4i(0,0,0,1), Vector4i(-1,0,0,0), Vector4i(0,-1,0,0), Vector4i(0,0,-1,0), Vector4i(0,0,0,-1)]
static var diagonals: Array[Vector4i]:
	get:
		if diagonals == []:
			diagonals = Globals.combinationsAggregate(uniagonals,2).filter(func(vec): return MagnitudeCheck(vec, 2))
		return diagonals
static var  triagonals: Array[Vector4i]:
	get:
		if triagonals == null: 
			triagonals = Globals.combinationsAggregate(uniagonals,3).filter(func(vec): return MagnitudeCheck(vec, 3))
		return triagonals
static var quadragonals: Array[Vector4i]:
	get:
		if quadragonals == null: 
			quadragonals = Globals.combinationsAggregate(uniagonals,4).filter(func(vec): return MagnitudeCheck(vec, 4))
		return quadragonals

func _ready() -> void:
	var s = getDirectionVectors()

func SetColor(isWhitePiece: bool):
	if isWhitePiece:
		isWhite = true
		modulate = Color.WHITE
	else: 
		isWhite = false
		modulate = Color.DIM_GRAY

func ArrayToVec(array: Array[Vector4i]) -> Vector4i:
	var r = []
	for i in array:
		r += i
	return r

static func MagnitudeCheck(vec: Vector4i, dims: int) -> bool:
	var magnitude
	match dims:
		1: magnitude = 1
		2: magnitude = Vector2i.ONE.length()
		3: magnitude = Vector3i.ONE.length()
		4: magnitude = Vector4i.ONE.length()
		_: return false
	return is_equal_approx(vec.length(), magnitude)

func getDirectionVectors() -> Array[Vector4i]:
	var vecs: Array[Vector4i] = []
	if Uniagonal: 
		vecs.append_array(uniagonals)
	if Diagonal: 
		vecs.append_array(diagonals)
	if Triagonal: 
		vecs.append_array(triagonals)
	if Quadragonal: 
		vecs.append_array(quadragonals)
	return vecs

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		game.Singleton.showLegalMoves(self, coord, getDirectionVectors(), Pawn, Rider)
		
