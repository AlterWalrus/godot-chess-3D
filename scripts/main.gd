extends Node

const BOARD_SIZE := 8
const DEFAULT_LAYOUT_PATH := "res://default.chess"
const SAVES_DIR := "user://saves/"
const MIN_ZOOM := 2.5
const MAX_ZOOM := 8.5
const ZOOM_STEP := 1.5

var piece_classes: Dictionary = {
	1: Pawn,
	2: Queen,
	3: King,
	4: Bishop,
	5: Horse,
	6: Rook,
}

var is_white_turn := true
var board_matrix: Array = []
var selected_piece: Piece
var prev_square: Square

var moving := false
var move_sensitivity := 0.004
var cam_zpos := 7.0:
	set(value):
		cam_zpos = clampf(value, MIN_ZOOM, MAX_ZOOM)

@onready var board := $Board
@onready var cam_pivot := $CamPivot
@onready var cam := $CamPivot/Camera3D
@onready var curr_turn := $CanvasLayer/CurrentTurn
@onready var gameover := $CanvasLayer/EndScreen
@onready var gameover_label := $CanvasLayer/EndScreen/Label
@onready var settings := $CanvasLayer/Settings

@export var square_scene: PackedScene


func _ready() -> void:
	settings.setup_layout.connect(_setup_layout)
	settings.save_game.connect(_save_current_layout)
	settings.toggled.connect(_on_settings_toggled)
	_build_board()
	_load_layout_from_file(DEFAULT_LAYOUT_PATH)


func _process(delta: float) -> void:
	cam.position.z = lerp(cam.position.z, cam_zpos, 0.2)
	if settings.settings_open:
		return
	var direction := Input.get_vector("left", "right", "up", "down")
	cam_pivot.rotation.y += direction.x * delta
	cam_pivot.rotation.x += direction.y * delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		moving = true
	elif event.is_action_released("move"):
		moving = false

	if event is InputEventMouseMotion and moving:
		cam_pivot.rotation.y += -event.relative.x * move_sensitivity
		cam_pivot.rotation.x += -event.relative.y * move_sensitivity

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_zpos -= ZOOM_STEP
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_zpos += ZOOM_STEP


func _build_board() -> void:
	for y in BOARD_SIZE:
		var row: Array = []
		for x in BOARD_SIZE:
			var square: Square = square_scene.instantiate()
			square.color = Color.WHITE if (x + y) % 2 == 0 else Color.BLACK
			square.position = Vector3(x, 0, y)
			square.coords = Vector2(x, y)
			square.square_selected.connect(_on_square_selected)
			board.add_child(square)
			row.append(square)
		board_matrix.append(row)


func _load_layout_from_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var layout: Dictionary = file.get_var()
	_setup_layout(layout)
	settings.load_layout(layout)


func _setup_layout(layout: Dictionary) -> void:
	_clean_board()
	for pos in layout.keys():
		var square: Square = board_matrix[pos.y][pos.x]
		var piece: Piece = piece_classes[layout[pos].piece].new()
		piece.class_index = layout[pos].piece
		piece.is_white = layout[pos].is_white
		piece.position = square.position
		square.piece = piece
		if piece is King:
			piece.died.connect(_on_king_died)
		board.add_child(piece)


func _clean_board() -> void:
	for row in board_matrix:
		for square in row:
			if square.piece:
				square.piece.queue_free()
				square.piece = null


func _save_current_layout(filename: String) -> void:
	var layout: Dictionary = {}
	for y in BOARD_SIZE:
		for x in BOARD_SIZE:
			var piece: Piece = board_matrix[y][x].piece
			if piece:
				layout[Vector2i(x, y)] = {
					"piece": piece.class_index,
					"is_white": piece.is_white,
				}

	if not DirAccess.dir_exists_absolute(SAVES_DIR):
		DirAccess.make_dir_recursive_absolute(SAVES_DIR)

	var file := FileAccess.open(SAVES_DIR + filename + ".chess", FileAccess.WRITE)
	file.store_var(layout)


func _on_square_selected(square: Square, piece: Piece) -> void:
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


func _select_piece(square: Square, piece: Piece) -> void:
	prev_square = square
	selected_piece = piece
	_select_animation(piece)


func _deselect_piece() -> void:
	_select_animation(selected_piece, false)
	prev_square = null
	selected_piece = null


func _move_piece(square: Square) -> void:
	if not selected_piece.move(prev_square.coords, square.coords, board_matrix):
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
	create_tween().tween_property(curr_turn, "modulate", color, 0.5)


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


func _on_king_died(is_white: bool) -> void:
	var text := "BLACK PIECES WIN" if is_white else "WHITE PIECES WIN"
	gameover_label.text = text
	gameover.show()
	var label_pos: float = gameover_label.position.x
	var tween := create_tween().set_trans(Tween.TRANS_CIRC).set_parallel()
	tween.tween_property(gameover, "position:x", 0.0, 0.5).from(-gameover.size.x)
	tween.tween_property(gameover_label, "position:x", label_pos, 0.7).from(-gameover.size.x)


func _lock_board(locked: bool) -> void:
	for row in board_matrix:
		for square in row:
			square.locked = locked


func _on_settings_toggled(is_open: bool) -> void:
	_lock_board(is_open)
