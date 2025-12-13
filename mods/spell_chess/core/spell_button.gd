class_name SpellButton
extends TextureButton

var inactive_color: Color = Color(0.36, 0.36, 0.36, 1.0)
var active_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var spell: Spell

static var spell_button = preload("res://mods/spell_chess/core/spell_button.tscn")

static func inst(_spell: Spell) -> SpellButton:
	var button: SpellButton =  spell_button.instantiate()
	button.spell = _spell
	return button

func _ready():
	self.modulate = inactive_color
	spell._on_spell_cast.connect(_on_spell_cast)
	spell.spell_chess.chess_logic.turn_changed.connect(update_spell_count_ui)
	update_spell_count_ui(spell.spell_chess.chess_logic.is_white_turn)

func _toggled(toggled_on):
	self.modulate = active_color if toggled_on else inactive_color

func _on_spell_cast():
	button_pressed = false
	update_spell_count_ui(spell.spell_chess.chess_logic.is_white_turn)

func update_spell_count_ui(white_turn: bool):
	if white_turn:
		$Label.text = str(spell.spell_count_white)
	else:
		$Label.text = str(spell.spell_count_black)
