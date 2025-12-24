extends Mod

var spell_used_this_turn := false
var spell_folder = "res://mods/spell_chess/spell_scripts/"
var spell_dict: Dictionary[String, GDScript]

func _ready():
	super()
	spell_dict = Globals.create_script_dict(spell_folder, func(spell): return spell is Spell)
	for spell in spell_dict:
		#add spell script as child
		var spell_inst: Spell = spell_dict[spell].new()

		#add spell button to chess UI
		var button: TextureButton = SpellButton.inst(spell_inst)
		spell_inst.spell_button = button
		spell_inst.spell_chess = self
		spell_inst._on_spell_cast.connect(_on_spell_cast)

		self.add_child(spell_inst)
		board_game.add_ui_element(button)

func _on_space_selected(_position: Vector4i, _piece: Control):
	for spell in get_children():
		if spell is Spell:
			spell.on_space_selected(_position, _piece)

func _on_spell_cast():
	spell_used_this_turn = true

func _turn_changed(_color):
	spell_used_this_turn = false
