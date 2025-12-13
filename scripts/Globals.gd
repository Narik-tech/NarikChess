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

# v = Vector4i(T, L, file, rank)
static func v4i_to_5d_coord(v: Vector4i) -> String:
	var T    := v.x
	var L    := v.y
	var file := v.z
	var rank := 8-v.w
	var file_char := char("a".unicode_at(0) + file)
	var rank_num  := rank
	return "T%d:L%d:%s%d" % [T, L, file_char, rank_num]

##For scripts in a given folder, returns Dictionary(filename, GDScript) for all scripts meeting filter criteria.
##Filter defaults to Mod scripts.
func create_script_dict(path: String, filter: Callable = func(m): return m is Mod) -> Dictionary[String, GDScript]:
	var scenes: Dictionary[String, GDScript] = {}
	var real_path := path
	
	
	#try orig path
	var dir := DirAccess.open(path)
	
	#try executable folder
	if dir == null:
		var exe_path = OS.get_executable_path().get_base_dir()
		var path_trimmed = path.replace("res://", "")
		dir = DirAccess.open(exe_path.path_join(path_trimmed))
		if dir == null:
			printlog("not found in " + exe_path.path_join(path_trimmed))
	
	if dir == null:
		push_warning("folder not found")
		return {}
			
	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var full_path := real_path.path_join(file_name)
		if dir.current_is_dir():
			printlog("[MOD]   Skipped directory: %s" % file_name)
		else:
			# Accept .gd, .gd.remap, .gdc, .gde
			var is_script_like := (
				file_name.ends_with(".gd")
				or file_name.ends_with(".gd.remap")
				or file_name.ends_with(".gdc")
				or file_name.ends_with(".gde") # Godot 4 debug bytecode
			)
			if not is_script_like:
				printlog("[MOD]   Skipped (not script-like file): %s" % file_name)
			else:
				var script_path := full_path
				if script_path.ends_with(".gd.remap"):
					script_path = script_path.get_basename()  # drop .remap

				var script = load(script_path)
				if not (script is GDScript):
					printlog("[MOD]   Skipped (not GDScript). Type:", typeof(script))
				else:
					var inst = script.new()
					if filter.call(inst):
						var mod_name := file_name.get_basename().get_basename()
						scenes[mod_name] = script
					else:
						printlog("[MOD]   Skipped (instance is not Mod), class:", inst.get_class())
		file_name = dir.get_next()
	dir.list_dir_end()
	printlog("[MOD] Finished. Total mods found:", scenes.size())
	return scenes

static func printlog(...args):
	pass
	#for log in args:
	#	print_debug(log)
