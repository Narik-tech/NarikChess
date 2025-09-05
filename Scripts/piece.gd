class_name Piece
extends TextureRect

signal piece_selected(coord: Vector4i)

var resource: PackedScene

var isWhite: bool = true
var coord: Vector2i
var full_coord: Vector4i:
	get:
		var p = get_parent()
		return Vector4i(p.coord.x,p.coord.y,coord.x,coord.y)
	set(val):
		coord.x = val.z
		coord.y = val.w

func _ready() -> void:
	var s = getDirectionVectors()
	piece_selected.connect(ChessGame.singleton._on_piece_selected)

@export_flags("Uniagonal", "Diagonal", "Triagonal","Quadragonal", "L") var directions = 0
@export_flags("Pawn", "Rider") var specialFlags = 0

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


func SetColor(isWhitePiece: bool):
	if isWhitePiece:
		isWhite = true
		modulate = Color.WHITE
	else: 
		isWhite = false
		modulate = Color.DIM_GRAY

func getDirectionVectors() -> Array[Vector4i]:
	var vecs: Array[Vector4i] = []
	if Uniagonal: 
		vecs.append_array(Globals.uniagonals)
	if Diagonal: 
		vecs.append_array(Globals.diagonals)
	if Triagonal: 
		vecs.append_array(Globals.triagonals)
	if Quadragonal: 
		vecs.append_array(Globals.quadragonals)
	if L: 
		vecs.append_array(Globals.knight)
	return vecs

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		piece_selected.emit(full_coord)
		
