extends Node

@onready var board: Board = $Board
@onready var game: Game = $Game
@onready var camera_rig: CameraRig = $CamPivot
@onready var settings: Settings = $CanvasLayer/Settings


func _ready() -> void:
	board.square_selected.connect(game.on_square_selected)
	board.king_died.connect(game.on_king_died)
	game.piece_moved.connect(_on_piece_moved)
	settings.piece_changed.connect(board.set_piece)
	settings.reset_layout.connect(board.clear)
	settings.restore_default.connect(_restore_default)
	settings.save_game.connect(board.save_layout)
	settings.load_game.connect(_on_load_game)
	settings.toggled.connect(_on_settings_toggled)
	_restore_default()


func _restore_default() -> void:
	var layout: Dictionary = board.load_layout(Board.DEFAULT_LAYOUT_PATH)
	if not layout.is_empty():
		settings.load_layout(layout)


func _on_load_game(filename: String) -> void:
	var layout: Dictionary = board.load_layout(Board.save_path(filename))
	if not layout.is_empty():
		settings.load_layout(layout)


func _on_piece_moved(from: Vector2i, to: Vector2i, piece: int, is_white: bool) -> void:
	settings.set_piece(from, 0, true)
	settings.set_piece(to, piece, is_white)


func _on_settings_toggled(is_open: bool) -> void:
	board.set_locked(is_open)
	camera_rig.paused = is_open
