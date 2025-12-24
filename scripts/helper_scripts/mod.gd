## Base mod hook that exposes board and move callbacks for gameplay extensions.
class_name Mod
extends Node

static var mod_texture_folder = "res://mods/textures/"

var board_game: BoardGame

var game_state: GameState:
	get:
		return board_game.game_state

func _ready():
	board_game.board_init._starting_board_created.connect(_on_starting_board)
	board_game.move_handling._on_chess_move.connect(_on_move_made)
	board_game.game_state._space_selected.connect(_on_space_selected)
	board_game.turn_handling.turn_changed.connect(_turn_changed)


func _on_starting_board(_board: Board):
	pass

func _on_move_made(_piece: Vector4i, _origin_board: Board, _dest_board: Board):
	pass

func _on_space_selected(_position: Vector4i, _piece: Control):
	pass

## If a move cannot be played, returns a string indicating why
func _can_play_move(_origin: Vector4i, _dest):
	return true

## If a turn cannot be submitted, returns a string indicating why
func _can_submit_turn():
	return true

func _turn_changed(_color):
	pass

static func load_texture_from_png(filename: String) -> Texture2D:
	#try orig path
	var bytes := FileAccess.get_file_as_bytes(filename)
	
	#try res:// texture folder
	if bytes == null or bytes.size() < 1:
		var path = mod_texture_folder.path_join(filename)
		bytes = FileAccess.get_file_as_bytes(path)
	
	#try executable texture folder
	if bytes == null or bytes.size() < 1:
		var exe_path = OS.get_executable_path()
		var texture_folder_trimmed = mod_texture_folder.replace("res://", "")
		bytes = FileAccess.get_file_as_bytes(exe_path.path_join(texture_folder_trimmed).path_join(filename))
	
	var img := Image.new()
	var err := img.load_png_from_buffer(bytes)
	if err != OK:
		push_error("Failed to load PNG from buffer: %s" % err)
		return null
	
	var img_texture = ImageTexture.create_from_image(img)
	return img_texture
