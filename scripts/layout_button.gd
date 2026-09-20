class_name LayoutButton
extends Button

var coords := Vector2i.ZERO
var is_white := true

func _ready() -> void:
	material = material.duplicate()

func switch_color():
	is_white = not is_white
	material.set_shader_parameter("invert_factor", 0.0 if is_white else 1.0)
