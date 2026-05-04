class_name Piece
extends Node3D

var is_white := true

@export var mesh: ArrayMesh

func _ready() -> void:
	var model = MeshInstance3D.new()
	model.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.roughness = 0.2
	mat.albedo_color = Color.WHITE if is_white else Color.BLACK
	model.material_override = mat
	add_child(model)
	
	if is_white:
		model.rotate_y(PI)


func is_path_clear(from: Vector2, to: Vector2, board_matrix: Array) -> bool:
	var step_x = sign(to.x - from.x)
	var step_y = sign(to.y - from.y)
	
	var curr_x = from.x + step_x
	var curr_y = from.y + step_y
	
	while curr_x != to.x or curr_y != to.y:
		if board_matrix[curr_y][curr_x].piece != null:
			return false
		curr_x += step_x
		curr_y += step_y
		
	return true


func die():
	await get_tree().create_timer(0.2).timeout
	var t = create_tween()
	t.tween_property(self, "scale", Vector3.ONE*0.01, 0.2)
	await t.finished
	queue_free()


@warning_ignore("unused_parameter")
func move(from: Vector2, to: Vector2, board_matrix) -> bool:
	return true
