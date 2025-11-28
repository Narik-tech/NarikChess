extends Node

const TEST_SCRIPT := "res://tests/test_chess_game.gd"
static var chess := preload("res://scenes/chess.tscn")
const mod_path := "res://mods"
const game_modes_path := "res://scripts/game_modes"

var mod_dict : Dictionary[String, String]
var game_mode_dict : Dictionary[String, String]


func _ready():
	run_tests()
	mod_dict = create_mod_dict(mod_path)
	game_mode_dict = create_mod_dict(game_modes_path)
	
	var mods : BoxContainer = $MainMenu/Options/Mods
	for child in mods.get_children():
		if child is CheckBox:
			child.queue_free()
		
	for mod in mod_dict:
		var checkbox = CheckBox.new()
		checkbox.text = mod
		mods.add_child(checkbox)
		mod_dict = create_mod_dict(mod_path)

	var dropdown: OptionButton = $MainMenu/Options/Modes/Options
	dropdown.clear()
	for mod_name in game_mode_dict.keys():
		dropdown.add_item(mod_name)
	dropdown.select(0)

func _on_start_pressed() -> void:
	var instance: Chess = chess.instantiate()
	
	var selected_mods: Array[Mod] = []
	for child in $MainMenu/Options/Mods.get_children():
		if child is CheckBox and child.button_pressed:
			var scene_path: String = mod_dict.get(child.text)
			var ps := load(scene_path)
			selected_mods.append(ps.new())
	
	var mode_dropdown = $MainMenu/Options/Modes/Options
	var mode_path = game_mode_dict.get(mode_dropdown.get_item_text(mode_dropdown.selected))
	selected_mods.append(load(mode_path).new())
	
	instance.load_mods(selected_mods)
	change_scene(instance)

func change_scene(scene: Node):
	for child in get_children():
		child.queue_free()
	add_child(scene)

func create_mod_dict(path: String) -> Dictionary[String, String]:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Cannot open folder: %s" % path)
	
	var scenes: Dictionary[String, String] = {}
	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".gd"):
			var full_path := path.path_join(file_name)
			var script := load(full_path)

			# Validate script type before accepting
			if script is GDScript:
				var inst = script.new()
				if inst is Mod:
					var base_name := file_name.get_basename()
					scenes[base_name] = full_path
		file_name = dir.get_next()
	dir.list_dir_end()
	return scenes

func run_tests():
	var test_node := preload(TEST_SCRIPT).new()
	self.add_child(test_node)
	test_node.run_tests()
