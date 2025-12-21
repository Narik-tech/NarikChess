## Entry point that runs tests, loads available mods and modes, and starts selected game scenes.
extends Node

const TEST_SCRIPT := "res://tests/test_chess_game.gd"
static var chess := preload("res://scenes/chess.tscn")
const mod_path := "res://mods"
const game_modes_path := "res://scripts/game_modes"

var mod_dict : Dictionary[String, GDScript]
var game_mode_dict : Dictionary[String, GDScript]

func _ready():
	#run_tests()
	mod_dict = Globals.create_script_dict(mod_path)
	game_mode_dict = Globals.create_script_dict(game_modes_path)
	
	var mods : BoxContainer = $MainMenu/Options/Mods
	for child in mods.get_children():
		if child is CheckBox:
			child.queue_free()
		
	for mod in mod_dict:
		var checkbox = CheckBox.new()
		checkbox.text = mod
		mods.add_child(checkbox)

	var dropdown: OptionButton = $MainMenu/Options/Modes/Options
	dropdown.clear()
	for mod_name in game_mode_dict.keys():
		dropdown.add_item(mod_name)
	dropdown.select(0)

func _on_start_pressed() -> void:
	var instance: BoardGame = chess.instantiate()
	
	var selected_mods: Array[Mod] = []
	for child in $MainMenu/Options/Mods.get_children():
		if child is CheckBox and child.button_pressed:
			var script: GDScript = mod_dict.get(child.text)
			selected_mods.append(script.new())
	
	var mode_dropdown = $MainMenu/Options/Modes/Options
	var mode_script: GDScript = game_mode_dict.get(mode_dropdown.get_item_text(mode_dropdown.selected))
	selected_mods.append(mode_script.new())
	#instance.load_mods(selected_mods)
	change_scene(instance)

func change_scene(scene: Node):
	for child in get_children():
		child.queue_free()
	add_child(scene)

func run_tests():
	var test_node := preload(TEST_SCRIPT).new()
	self.add_child(test_node)
	test_node.run_tests()
