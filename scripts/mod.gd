## Base mod hook that exposes board and move callbacks for gameplay extensions.
class_name Mod
extends Node

static var mod_texture_folder = "res://mods/textures/"

var chess: Chess:
	get:
		return get_parent()

var chess_logic: ChessLogic:
	get:
		return chess.chess_logic

func _ready():
	chess.on_starting_board_created.connect(_on_starting_board)
	chess.on_move_made.connect(_on_move_made)
	chess.on_empty_space_selected.connect(_on_empty_space_selected)
	chess.on_empty_space_selected.connect(_on_any_select)
	chess.on_piece_selected.connect(_on_piece_selected)

func _on_starting_board(_board: Board):
	pass

func _on_move_made(_piece: Vector4i, _origin_board: Board, _dest_board: Board):
	pass

func _on_piece_selected(_piece: Piece):
	_on_any_select(_piece.board, _piece.coord)

func _on_empty_space_selected(_board: Board, _coord: Vector2i):
	pass

## Called when an empty space or piece is selected
func _on_any_select(_board: Board, _coord: Vector2i):
	pass

## If a move cannot be played, returns a string indicating why
func _can_play_move(_origin: Vector4i, _dest):
	return true

## If a turn cannot be submitted, returns a string indicating why
func _can_submit_turn():
	return true

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
