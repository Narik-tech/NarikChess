@tool
extends Resource
class_name ChessPieceDef

@export_category("Visuals")
@export var white_texture: Texture2D

@export_category("Directions")
@export var uniagonal: bool
@export var diagonal: bool
@export var triagonal: bool
@export var quadragonal: bool
@export var knight: bool

@export_category("Flags")
@export var pawn: bool
@export var rider: bool
