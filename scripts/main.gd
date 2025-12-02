## Entry point that runs tests, loads available mods and modes, and starts selected game scenes.
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
	var scenes: Dictionary[String, String] = {}

	# Try the virtual path first (works in the editor if mods/ is in the project)
	var dir := DirAccess.open(path)
	var real_path := path

	# If that fails (exported game), fall back to a folder next to the .exe
	if dir == null and path.begins_with("res://"):
		var folder_name := path.get_file()        # "mods" from "res://mods"
		var exe_dir := OS.get_executable_path().get_base_dir()
		var fs_path := exe_dir.path_join(folder_name)

		dir = DirAccess.open(fs_path)
		if dir == null:
			push_error("[MOD] Cannot open folder: %s or %s" % [path, fs_path])
			return scenes
		else:
			printlog("[MOD] Using external mods folder:", fs_path)
			real_path = fs_path
	elif dir == null:
		push_error("[MOD] Cannot open folder: %s" % path)
		return scenes

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
				if script == null:
					push_error("[MOD]   ERROR: failed to load script: %s" % script_path)
				elif not (script is GDScript):
					printlog("[MOD]   Skipped (not GDScript). Type:", typeof(script))
				else:
					var inst = script.new()
					if inst is Mod:
						var mod_name := file_name.get_basename().get_basename()
						scenes[mod_name] = script_path
						printlog("[MOD]   ADDED mod:", mod_name, "=>", script_path)
					else:
						printlog("[MOD]   Skipped (instance is not Mod), class:", inst.get_class())

		file_name = dir.get_next()

	dir.list_dir_end()

	printlog("[MOD] Finished. Total mods found:", scenes.size())
	return scenes

func run_tests():
	var test_node := preload(TEST_SCRIPT).new()
	self.add_child(test_node)
	test_node.run_tests()

func printlog(...args):
	pass
