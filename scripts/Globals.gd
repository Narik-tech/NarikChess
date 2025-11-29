## Provides shared helpers for vector calculations, validity checks, and precomputed movement directions.
extends Node

func _ready():
	calculate_agonals()

static func instanceSceneAtCoord(coord, parent, scene):
	var instance = scene.instantiate()
	if instance is Node2D or instance is Control:
		instance.position = coord
	parent.add_child(instance)
	return instance

static var uniagonals: Array[Vector4i]
static var diagonals: Array[Vector4i]
static var triagonals: Array[Vector4i]
static var quadragonals: Array[Vector4i]
static var knight: Array[Vector4i]

static func calculate_agonals():
	var start = -2
	var end = 3
	var mult = Vector4i(2,1,1,1)
	for x in range(start, end): for y in range(start, end): for z in range(start, end): for w in range(start, end):
		var vec = Vector4i(x,y,z,w)
		var mag = magnitude(vec)
		if dims_count(vec) != mag:
			if mag == 3: 
				knight.append(vec*mult)
		elif mag == 1: 
			uniagonals.append(vec*mult)
		elif mag == 2:
			diagonals.append(vec*mult)
		elif mag == 3: 
			triagonals.append(vec*mult)
		elif mag == 4: 
			quadragonals.append(vec*mult)

static func dims_count(vec: Vector4i) -> int:
	var dims = 0 if vec.x == 0 else 1 
	dims += 0 if vec.y == 0 else 1
	dims += 0 if vec.z == 0 else 1 
	dims += 0 if vec.w == 0 else 1
	return dims

static func magnitude(vec: Vector4i) -> int:
	return abs(vec.x) + abs(vec.y) + abs(vec.z) + abs(vec.w)

static func is_valid_node(node: Node) -> bool:
	if not is_instance_valid(node):
		return false
	if node.is_queued_for_deletion():
		return false
	return true
