extends SceneTree

func _init() -> void:
	var test_node := preload("res://tests/test_chess_game.gd").new()
	get_root().add_child(test_node)
	var success := test_node.run()
	if success:
		print("All tests passed")
		quit()
	else:
		push_error("Some tests failed")
		quit(1)
