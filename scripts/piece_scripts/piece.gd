## Base control for board occupants, handling position metadata and click signalling.
class_name Piece
extends Control

signal on_piece_clicked(coord: Vector4i)

static var piece_script = preload("res://scripts/piece_scripts/piece.gd")
static var square_scene = preload("res://scenes/pieces/solid_color_piece.tscn")
static var texture_piece = preload("res://scenes/pieces/texture_piece.tscn")

static func color_inst(color: Color, script: GDScript = Piece) -> Piece:
	var sq := square_scene.instantiate()
	sq.set_script(script)
	sq.color = color
	return sq

static func texture_inst(texture: Texture2D, script: GDScript = Piece) -> Piece:
	var sq = texture_piece.instantiate()
	sq.set_script(script)
	sq.texture = texture
	return sq as Piece

var is_overlay: bool = false

var coord: Vector2i
var board: Board:
	get:
		return get_parent()

var full_coord: Vector4i:
	get:
		var p = get_parent()
		return Vector4i(p.coord.x,p.coord.y,coord.x,coord.y)
	set(val):
		coord.x = val.z
		coord.y = val.w

func blocks_movement(_piece_moving: ChessPiece) -> bool:
	push_warning("blocks_movement function not set on piece " + name + ", defaulting to false.")
	return false

func piece_ready():
	pass

func _ready() -> void:
	self.gui_input.connect(_on_gui_input)
	piece_ready()

func _on_click():
	pass

func _on_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed):
		return
	Chess.singleton.on_piece_selected.emit(self)
	on_piece_clicked.emit(full_coord)
	_on_click()
