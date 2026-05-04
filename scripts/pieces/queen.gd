class_name Queen
extends Piece

func _init() -> void:
	mesh = load("res://models/queen.obj")


func move(from: Vector2, to: Vector2, board_matrix) -> bool:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	if dx != 0 and dy != 0 and dx != dy:
		return false
		
	return is_path_clear(from, to, board_matrix)
