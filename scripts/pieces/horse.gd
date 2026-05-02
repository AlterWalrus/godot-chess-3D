class_name Horse
extends Piece

func _init() -> void:
	mesh = load("res://models/horse.obj")


func move(from: Vector2, to: Vector2, board_matrix) -> bool:
	if not super.move(from, to, board_matrix):
		return false
	
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	return (dx == 2 and dy == 1) or (dx == 1 and dy == 2)
