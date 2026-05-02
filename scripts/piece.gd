class_name Piece
extends Node3D

var is_white := true

@export var mesh: ArrayMesh


func _ready() -> void:
	var model = MeshInstance3D.new()
	model.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.roughness = 0.3
	mat.albedo_color = Color.WHITE if is_white else Color.BLACK
	model.material_override = mat
	add_child(model)
	
	if is_white:
		model.rotate_y(PI)


@warning_ignore("unused_parameter")
func move(square: Square):
	return true
