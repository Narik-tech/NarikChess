extends TextureButton

var inactive_color: Color = Color(0.36, 0.36, 0.36, 1.0)
var active_color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready():
	self.modulate = inactive_color

func _toggled(toggled_on):
	self.modulate = active_color if toggled_on else inactive_color
