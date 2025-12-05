extends Mod

var spell_folder = "res://mods/spell_chess/spells/"
var spell_dict: Dictionary[String, GDScript]
var spell_button = preload("res://mods/spell_chess/spell_button.tscn")

func _ready():
	super()
	spell_dict = Globals.create_script_dict(spell_folder, func(spell): return spell is Spell)
	for spell in spell_dict:
		#add spell script as child
		var spell_inst: Spell = spell_dict[spell].new()

		#add spell button to chess UI
		var button: TextureButton = spell_button.instantiate()
		spell_inst.spell_button = button
		spell_inst.spell_chess = self

		self.add_child(spell_inst)
		chess.add_mod_ui(button)

func _on_any_select(_board: Board, _coord: Vector2i):
	for spell in get_children():
		if spell is Spell:
			spell.on_any_select(_board, _coord)
