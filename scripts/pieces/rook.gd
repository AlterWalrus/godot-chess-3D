class_name Rook
extends Piece

func _init() -> void:
	mesh = load("res://models/rook.obj")

func move(from: Vector2, to: Vector2, board_matrix) -> bool:
	var dx = to.x - from.x
	var dy = to.y - from.y
	
	if dx != 0 and dy != 0:
		return false
		
	return is_path_clear(from, to, board_matrix)
