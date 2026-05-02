extends Node

var is_white_turn := true
var board_list: Array[Square] = []
var selected_piece: Piece
var prev_square: Square

var moving_sens := 0.004
var moving := false

@onready var board := $Board
@onready var cam := $CamPivot
@onready var curr_turn := $CanvasLayer/CurrentTurn

@export var square_scene: PackedScene

func _ready() -> void:
	_set_board()
	_set_pieces()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		moving = true
	
	if event.is_action_released("move"):
		moving = false
	
	if event is InputEventMouseMotion and moving:
		cam.rotation.y += -event.relative.x * moving_sens
		cam.rotation.x += -event.relative.y * moving_sens


func _on_square_selected(square: Square, piece: Piece):
	if not piece and not selected_piece:
		return
	
	if piece and not selected_piece:
		if piece.is_white != is_white_turn:
			return
	
	if piece and selected_piece:
		if piece.is_white == is_white_turn:
			selected_piece.position.y = 0
			prev_square = null
			selected_piece = null
			return
	
	if selected_piece:
		if selected_piece.move(square):
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
		
		var t = create_tween()
		t.set_trans(Tween.TRANS_CIRC)
		t.tween_property(piece, "position:y", 0.5, 0.2)


func _set_board():
	for y in range(8):
		for x in range(8):
			var sqr: Square = square_scene.instantiate()
			
			var is_white = !(x+y) & 1
			sqr.color = Color.WHITE if is_white else Color.BLACK
			sqr.position = Vector3(x, 0, y)
			sqr.coords = Vector2(x, y)
			
			sqr.square_selected.connect(_on_square_selected)
			
			board_list.append(sqr)
			board.add_child(sqr)


func _set_pieces():
	#Pawns
	for i in range(8, 16):
		var bl := Pawn.new()
		bl.is_white = false
		bl.position = board_list[i].position
		board_list[i].piece = bl
		board.add_child(bl)
		
		var j = i+40
		var wh := Pawn.new()
		wh.position = board_list[j].position
		board_list[j].piece = wh
		board.add_child(wh)
	
	#Main line
	var line = [Rook, Horse, Bishop, Queen, King, Bishop, Horse, Rook]
	for i in range(8):
		#Black
		var nw = line[i].new()
		nw.is_white = false
		nw.position = board_list[i].position
		board_list[i].piece = nw
		board.add_child(nw)
		
		#White
		var j = i+56
		nw = line[i].new()
		nw.position = board_list[j].position
		board_list[j].piece = nw
		board.add_child(nw)
