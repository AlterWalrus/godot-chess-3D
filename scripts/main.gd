extends Node

var piece_map = [Pawn, Queen, King, Bishop, Horse, Rook]

var is_white_turn := true
var board_matrix = []
var selected_piece: Piece
var prev_square: Square

var moving_sens := 0.004
var moving := false
var cam_zpos := 7.0:
	set(x):
		var min_zoom := 2.5
		var max_zoom := 8.5
		cam_zpos = clamp(x, min_zoom, max_zoom)

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
	_build_board()
	
	var default_layout_path = "res://default.chess"
	if not FileAccess.file_exists(default_layout_path):
		print("shit aint there lil bro")
		return
	var file = FileAccess.open(default_layout_path, FileAccess.READ)
	var layout_dict: Dictionary = file.get_var()
	_setup_layout(layout_dict)


func _process(delta: float) -> void:
	var dir = Input.get_vector("left", "right", "up", "down")
	cam_pivot.rotation.y += dir.x * delta
	cam_pivot.rotation.x += dir.y * delta
	
	cam.position.z = lerp(cam.position.z, cam_zpos, 0.2)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		moving = true
	
	if event.is_action_released("move"):
		moving = false
	
	if event is InputEventMouseMotion and moving:
		cam_pivot.rotation.y += -event.relative.x * moving_sens
		cam_pivot.rotation.x += -event.relative.y * moving_sens
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			cam_zpos -= 1.5
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			cam_zpos += 1.5


func _on_king_died(is_white):
	var tx = "BLACK PIECES WIN" if is_white else "WHITE PIECES WIN"
	gameover_label.text = tx
	gameover.show()
	var og_label_position = gameover_label.position.x
	var t = create_tween().set_trans(Tween.TRANS_CIRC).set_parallel()
	t.tween_property(gameover, "position:x", 0, 0.5).from(-gameover.size.x)
	t.tween_property(gameover_label, "position:x", og_label_position, 0.7).from(-gameover.size.x)


func _on_square_selected(square: Square, piece: Piece):
	if not piece and not selected_piece:
		return
	
	if piece and not selected_piece:
		if piece.is_white != is_white_turn:
			return
	
	if piece and selected_piece:
		var same_piece = (piece == selected_piece)
		if piece.is_white == is_white_turn:
			_select_animation(selected_piece, false)
			prev_square = null
			selected_piece = null
		if same_piece:
			return
	
	if selected_piece:
		if not selected_piece.move(prev_square.coords, square.coords, board_matrix):
			_wrong_move_animation()
			return
		
		if square.piece != null:
			square.piece.die()
		
		var t = create_tween()
		t.set_trans(Tween.TRANS_CIRC)
		t.tween_property(selected_piece, "position", square.position, 0.5)
		
		square.piece = selected_piece
		
		prev_square.piece = null
		selected_piece = null
		
		#Update current turn
		is_white_turn = not is_white_turn
		var col = Color.WHITE if is_white_turn else Color.BLACK
		create_tween().tween_property(curr_turn, "modulate", col, 0.5)
			
	else:
		prev_square = square
		selected_piece = piece
		_select_animation(piece)


func _build_board():
	for y in range(8):
		var row = []
		for x in range(8):
			var sqr: Square = square_scene.instantiate()
			var is_white = !(x+y) & 1
			sqr.color = Color.WHITE if is_white else Color.BLACK
			sqr.position = Vector3(x, 0, y)
			sqr.coords = Vector2(x, y)
			sqr.square_selected.connect(_on_square_selected)
			board.add_child(sqr)
			row.append(sqr)
		board_matrix.append(row)


func _clean_board():
	var cleared_pieces := 0
	for y in range(8):
		for x in range(8):
			if board_matrix[y][x].piece:
				board_matrix[y][x].piece.queue_free()
				board_matrix[y][x].piece = null
				cleared_pieces += 1
	print(cleared_pieces, " pieces cleared")


func _setup_layout(layout: Dictionary):
	_clean_board()
	for pos in layout.keys():
		var piece_class: int = layout[pos].piece
		var new_piece: Piece = piece_map[piece_class].new()
		new_piece.class_index = layout[pos].piece
		new_piece.is_white = layout[pos].is_white
		new_piece.position = board_matrix[pos.y][pos.x].position
		board_matrix[pos.y][pos.x].piece = new_piece
		board.add_child(new_piece)
	print(len(layout), " pieces added")


func _save_current_layout():
	var layout := {}
	for y in range(8):
		for x in range(8):
			if board_matrix[y][x].piece:
				layout.set(Vector2i(x, y), {
					"piece": board_matrix[y][x].piece.class_index,
					"is_white": board_matrix[y][x].piece.is_white
				})


func _select_animation(piece: Piece, selected: bool = true):
	var t = create_tween()
	t.set_trans(Tween.TRANS_CIRC)
	t.tween_property(piece, "position:y", 0.5 if selected else 0.0, 0.2)


func _wrong_move_animation():
	var mag := 0.1
	var s = create_tween()
	s.tween_property(selected_piece, "rotation:z", mag, 0.1)
	s.tween_property(selected_piece, "rotation:z", -mag, 0.1)
	s.tween_property(selected_piece, "rotation:z", mag*0.6, 0.1)
	s.tween_property(selected_piece, "rotation:z", -mag*0.6, 0.1)
	s.tween_property(selected_piece, "rotation:z", 0, 0.1)
