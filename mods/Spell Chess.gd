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
		self.add_child(spell_inst)
		
		#add spell button to chess UI
		var button: TextureButton = spell_button.instantiate()
		button.texture_normal = spell_inst.spell_texture()
		button.pressed.connect(spell_inst._on_spell_selected)
		chess.add_mod_ui(button)
		
		
		
