class_name Piece
extends TextureRect

signal piece_selected(coord: Vector4i)

var coord: Vector2i

var resource: PackedScene
var is_white: bool = true
var has_moved: bool = false
var board: Board:
	get:
		return get_parent()
		
var full_coord: Vector4i:
	get:
		var p = get_parent()
		return Vector4i(p.coord.x,p.coord.y,coord.x,coord.y)
	set(val):
		coord.x = val.z
		coord.y = val.w

func _ready() -> void:
	piece_selected.connect(ChessGame.singleton._on_piece_selected)

@export_flags("Uniagonal", "Diagonal", "Triagonal","Quadragonal", "L") var directions = 0
@export_flags("Pawn", "Rider") var specialFlags = 0

var uniagonal: 
	get: return 1 & directions != 0
var diagonal: 
	get: return 2 & directions != 0
var triagonal: 
	get: return 4 & directions != 0
var quadragonal: 
	get: return 8 & directions != 0
var knight: 
	get: return 16 & directions != 0
var pawn: 
	get: return 1 & specialFlags != 0
var rider: 
	get: return 2 & specialFlags != 0


func set_color(isWhitePiece: bool):
	if isWhitePiece:
		is_white = true
		modulate = Color.WHITE
	else: 
		is_white = false
		modulate = Color.DIM_GRAY

func get_direction_vectors() -> Array[Vector4i]:
	var vecs: Array[Vector4i] = []
	if uniagonal:
		vecs.append_array(Globals.uniagonals.filter(is_forward) if pawn else Globals.uniagonals)
	if diagonal: 
		vecs.append_array(Globals.diagonals.filter(is_forward) if pawn else Globals.diagonals)
	if triagonal: 
		vecs.append_array(Globals.triagonals)
	if quadragonal: 
		vecs.append_array(Globals.quadragonals)
	if knight: 
		vecs.append_array(Globals.knight)
	return vecs

func is_forward(vec: Vector4i) -> bool:
	#remove for Brawn
	if abs(vec.x) + abs(vec.y) > 0 and abs(vec.z) + abs(vec.w) > 0: return false
	
	return vec.y < 0 or vec.w < 0 if is_white else vec.y > 0 or vec.w > 0

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	if not board.board_playable():
		return
	
	if not board.is_white == is_white:
		return
	
	piece_selected.emit(full_coord)
		
