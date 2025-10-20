extends Node

static var chess := preload("res://Scenes/chess.tscn")
const mod_path := "res://mods"
var mod_dict : Dictionary[String, String]

func _ready():
	mod_dict = create_mod_dict()
	for mod in mod_dict:
		var checkbox = CheckBox.new()
		checkbox.text = mod
		$MainMenu/Mods.add_child(checkbox)

func change_scene(scene: Node):
	for child in get_children():
		child.queue_free()
	add_child(scene)

func _on_start_pressed() -> void:
	var instance:ChessGame = chess.instantiate()
	change_scene(instance)

func create_mod_dict() -> Dictionary[String, String]:
	var dir := DirAccess.open(mod_path)
	if dir == null:
		push_error("Cannot open folder: %s" % mod_path)
	
	var scenes : Dictionary[String, String] = {}
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var full_path := mod_path.path_join(file_name)
			var base_name := file_name.get_basename()  # removes extension
			scenes[base_name] = full_path
		file_name = dir.get_next()
	dir.list_dir_end()
	return scenes
