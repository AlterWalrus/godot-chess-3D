class_name Bishop
extends Piece

func _init() -> void:
	mesh = load("res://models/bishop.obj")


func move(from: Vector2, to: Vector2, board_matrix) -> bool:
	if not super.move(from, to, board_matrix): return false
	
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	if dx != dy: 
		return false
		
	return is_path_clear(from, to, board_matrix)
