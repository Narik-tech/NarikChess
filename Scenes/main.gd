extends Node

static var chess := preload("res://Scenes/chess_game.tscn")

func change_scene(scene: Node):
	for child in get_children():
		child.queue_free()
	add_child(scene)

func _on_5d_chess_pressed() -> void:
	var instance:ChessGame = chess.instantiate()
	change_scene(instance)

func _on_conway_chess_pressed() -> void:
	var instance:ChessGame = chess.instantiate()
	instance.conway_time = true
	change_scene(instance)
