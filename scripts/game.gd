class_name Game
extends Node

@export var board: Board
@export var turn_indicator: Control
@export var end_screen: Control

var is_white_turn := true
var selected_piece: Piece
var prev_square: Square


func on_square_selected(square: Square, piece: Piece) -> void:
	if piece == null and selected_piece == null:
		return

	if selected_piece == null:
		if piece.is_white == is_white_turn:
			_select_piece(square, piece)
		return

	if piece == selected_piece:
		_deselect_piece()
		return

	if piece != null and piece.is_white == is_white_turn:
		_deselect_piece()
		_select_piece(square, piece)
		return

	_move_piece(square)


func on_king_died(is_white: bool) -> void:
	var text := "BLACK PIECES WIN" if is_white else "WHITE PIECES WIN"
	var label: Label = end_screen.get_node("Label")
	label.text = text
	end_screen.show()
	var label_pos: float = label.position.x
	var tween := create_tween().set_trans(Tween.TRANS_CIRC).set_parallel()
	tween.tween_property(end_screen, "position:x", 0.0, 0.5).from(-end_screen.size.x)
	tween.tween_property(label, "position:x", label_pos, 0.7).from(-end_screen.size.x)


func _select_piece(square: Square, piece: Piece) -> void:
	prev_square = square
	selected_piece = piece
	_select_animation(piece)


func _deselect_piece() -> void:
	_select_animation(selected_piece, false)
	prev_square = null
	selected_piece = null


func _move_piece(square: Square) -> void:
	if not selected_piece.move(prev_square.coords, square.coords, board.squares):
		_wrong_move_animation()
		return

	if square.piece != null:
		square.piece.die()

	var tween := create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(selected_piece, "position", square.position, 0.5)

	square.piece = selected_piece
	prev_square.piece = null
	selected_piece = null
	_end_turn()


func _end_turn() -> void:
	is_white_turn = not is_white_turn
	var color := Color.WHITE if is_white_turn else Color.BLACK
	create_tween().tween_property(turn_indicator, "modulate", color, 0.5)


func _select_animation(piece: Piece, selected: bool = true) -> void:
	create_tween().set_trans(Tween.TRANS_CIRC).tween_property(piece, "position:y", 0.5 if selected else 0.0, 0.2)


func _wrong_move_animation() -> void:
	var magnitude := 0.1
	var tween := create_tween()
	tween.tween_property(selected_piece, "rotation:z", magnitude, 0.1)
	tween.tween_property(selected_piece, "rotation:z", -magnitude, 0.1)
	tween.tween_property(selected_piece, "rotation:z", magnitude * 0.6, 0.1)
	tween.tween_property(selected_piece, "rotation:z", -magnitude * 0.6, 0.1)
	tween.tween_property(selected_piece, "rotation:z", 0.0, 0.1)
