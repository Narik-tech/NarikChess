## Summary: Resource defining chess piece visuals, movement vectors, and pawn behavior helpers.
@tool
extends Resource
class_name ChessPieceDef

@export_category("Visuals")
@export var white_texture: Texture2D

@export_category("Directions")
@export var uniagonal: bool
@export var diagonal: bool
@export var triagonal: bool
@export var quadragonal: bool
@export var knight: bool

@export_category("Flags")
@export var pawn: bool
@export var rider: bool

func get_direction_vectors(is_white: bool) -> Array[Vector4i]:
	var vecs: Array[Vector4i] = []
	if uniagonal:
		vecs.append_array(Globals.uniagonals.filter(func(vec): return is_forward(vec, is_white)) if pawn else Globals.uniagonals)
	if diagonal: 
		vecs.append_array(Globals.diagonals.filter(func(vec): return is_forward(vec, is_white)) if pawn else Globals.diagonals)
	if triagonal: 
		vecs.append_array(Globals.triagonals)
	if quadragonal: 
		vecs.append_array(Globals.quadragonals)
	if knight: 
		vecs.append_array(Globals.knight)
	return vecs

func is_forward(vec: Vector4i, is_white :bool) -> bool:
	#remove for Brawn
	if abs(vec.x) + abs(vec.y) > 0 and abs(vec.z) + abs(vec.w) > 0: return false
	
	return vec.y < 0 or vec.w < 0 if is_white else vec.y > 0 or vec.w > 0
