extends Node

var is_white_turn := true
var board_list: Array[Square] = []
var selected_piece: Piece
var prev_square: Square

@onready var board := $Board
@onready var cam := $CamPivot

@export var square_scene: PackedScene
@export var pawn_scene: PackedScene
'''
@export var rook_scene: PackedScene
@export var horse_scene: PackedScene
@export var bishop_scene: PackedScene
@export var queen_scene: PackedScene
@export var king_scene: PackedScene
'''

func _ready() -> void:
	_set_board()
	for i in range(8):
		var new: Pawn = pawn_scene.instantiate()
		new.position = board_list[i].position
		board_list[i].piece = new
		board.add_child(new)


func _process(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	cam.rotation.y += dir * delta


func _on_square_selected(square: Square, piece: Piece):
	if selected_piece:
		if selected_piece.move(square.coords):
			var t = create_tween()
			t.set_trans(Tween.TRANS_CIRC)
			t.tween_property(selected_piece, "position", square.position, 0.5)
			square.piece = selected_piece
			prev_square.piece = null
			selected_piece = null
	else:
		prev_square = square
		selected_piece = piece


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
