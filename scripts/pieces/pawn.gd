class_name Pawn
extends Piece

func _init() -> void:
	mesh = load("res://models/pawn.obj")


func move(from: Vector2, to: Vector2, board_matrix) -> bool:
	var dx = to.x - from.x
	var dy = to.y - from.y
	
	var dir = -1 if is_white else 1
	var start_row = 6 if is_white else 1 
	
	var target_square: Square = board_matrix[to.y][to.x]
	
	if dx == 0:
		if target_square.piece != null:
			return false
			
		if dy == dir: 
			return true
		
		if dy == dir * 2 and from.y == start_row:
			var mid_square: Square = board_matrix[from.y + dir][from.x]
			if mid_square.piece == null:
				return true
		
	elif abs(dx) == 1 and dy == dir:
		if target_square.piece != null and target_square.piece.is_white != self.is_white:
			return true
			
	return false
