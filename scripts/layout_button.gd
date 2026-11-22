class_name LayoutButton
extends Button

var coords := Vector2i.ZERO
var is_white := true
var piece := 0

func _ready() -> void:
	material = material.duplicate()

func switch_color() -> void:
	set_color(not is_white)

func set_color(white: bool) -> void:
	is_white = white
	material.set_shader_parameter("invert_factor", 0.0 if is_white else 1.0)
