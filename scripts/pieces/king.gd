class_name King
extends Piece

signal died

func _init() -> void:
	mesh = load("res://models/king.obj")

func move(from: Vector2, to: Vector2, _board_matrix: Array) -> bool:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	
	return dx <= 1 and dy <= 1


func die():
	died.emit(is_white)
	super.die()
