extends Node

@onready var board := $Board
@onready var cam := $CamPivot

@export var square_scene: PackedScene

func _ready() -> void:
	_set_board()


func _process(delta: float) -> void:
	var dir = Input.get_axis("left", "right")
	cam.rotation.y += dir * delta


func _set_board():
	for y in range(8):
		for x in range(8):
			var sqr: Square = square_scene.instantiate()
			
			var is_white = (x + y**2) % 2 == 0
			sqr.color = Color.WHITE if is_white else Color.BLACK
			sqr.position = Vector3(x, 0, y)
			sqr.coords = Vector2(x, y)
			
			board.add_child(sqr)
