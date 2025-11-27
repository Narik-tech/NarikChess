extends Node

const TEST_SCRIPT := "res://tests/test_chess_game.gd"
static var chess := preload("res://scenes/chess.tscn")
const mod_path := "res://mods"
var mod_dict : Dictionary[String, String]

func _ready():
	run_tests()
	mod_dict = create_mod_dict()
	for mod in mod_dict:
		var checkbox = CheckBox.new()
		checkbox.text = mod
		$MainMenu/Mods.add_child(checkbox)

func _on_start_pressed() -> void:
	var instance: Chess = chess.instantiate()
	
	var selected_mods: Array[Mod] = []
	for child in $MainMenu/Mods.get_children():
		if child is CheckBox and child.button_pressed:
			var scene_path: String = mod_dict.get(child.text)
			var ps := load(scene_path)
			selected_mods.append(ps.instantiate())
	
	instance.load_mods(selected_mods)
	change_scene(instance)

func change_scene(scene: Node):
	for child in get_children():
		child.queue_free()
	add_child(scene)

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

func run_tests():
	var test_node := preload(TEST_SCRIPT).new()
	self.add_child(test_node)
	test_node.run_tests()
