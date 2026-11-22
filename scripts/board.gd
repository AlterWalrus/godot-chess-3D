class_name Board
extends Node3D

signal square_selected(square: Square, piece: Piece)
signal king_died(is_white: bool)

const BOARD_SIZE := 8
const DEFAULT_LAYOUT_PATH := "res://default.chess"
const SAVES_DIR := "user://saves/"

var piece_classes: Dictionary = {
	1: Pawn,
	2: Queen,
	3: King,
	4: Bishop,
	5: Horse,
	6: Rook,
}

@export var square_scene: PackedScene

var squares: Array = []


func _ready() -> void:
	for y in BOARD_SIZE:
		var row: Array = []
		for x in BOARD_SIZE:
			var square: Square = square_scene.instantiate()
			square.color = Color.WHITE if (x + y) % 2 == 0 else Color.BLACK
			square.position = Vector3(x, 0, y)
			square.coords = Vector2i(x, y)
			square.square_selected.connect(square_selected.emit)
			add_child(square)
			row.append(square)
		squares.append(row)


func square_at(coords: Vector2i) -> Square:
	return squares[coords.y][coords.x]


func setup_layout(layout: Dictionary) -> void:
	clear()
	for coords in layout.keys():
		var entry: Dictionary = layout[coords]
		spawn_piece(coords, entry.piece, entry.is_white)


func clear() -> void:
	for row in squares:
		for square in row:
			if square.piece:
				square.piece.queue_free()
				square.piece = null


func to_layout() -> Dictionary:
	var layout: Dictionary = {}
	for y in BOARD_SIZE:
		for x in BOARD_SIZE:
			var piece: Piece = squares[y][x].piece
			if piece:
				layout[Vector2i(x, y)] = {
					"piece": piece.class_index,
					"is_white": piece.is_white,
				}
	return layout


func save_layout(filename: String) -> void:
	if not DirAccess.dir_exists_absolute(SAVES_DIR):
		DirAccess.make_dir_recursive_absolute(SAVES_DIR)
	var file := FileAccess.open(SAVES_DIR + filename + ".chess", FileAccess.WRITE)
	file.store_var(to_layout())


func load_layout(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	var layout: Dictionary = file.get_var()
	setup_layout(layout)
	return layout


func set_locked(locked: bool) -> void:
	for row in squares:
		for square in row:
			square.locked = locked


func spawn_piece(coords: Vector2i, class_index: int, is_white: bool) -> void:
	var square: Square = square_at(coords)
	var piece: Piece = piece_classes[class_index].new()
	piece.class_index = class_index
	piece.is_white = is_white
	piece.position = square.position
	square.piece = piece
	if piece is King:
		piece.died.connect(king_died.emit)
	add_child(piece)
