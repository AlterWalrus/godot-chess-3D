class_name King
extends Piece

func _init() -> void:
	mesh = load("res://models/bishop.obj")

func move(from: Vector2, to: Vector2, board_matrix: Array) -> bool:
	if not super.move(from, to, board_matrix):
		return false
	
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	return dx <= 1 and dy <= 1
