extends Node

@onready var board: Board = $Board
@onready var game: Game = $Game
@onready var camera_rig: CameraRig = $CamPivot
@onready var settings: Settings = $CanvasLayer/Settings


func _ready() -> void:
	board.square_selected.connect(game.on_square_selected)
	board.king_died.connect(game.on_king_died)
	settings.setup_layout.connect(board.setup_layout)
	settings.save_game.connect(board.save_layout)
	settings.toggled.connect(_on_settings_toggled)

	var layout: Dictionary = board.load_layout(Board.DEFAULT_LAYOUT_PATH)
	if not layout.is_empty():
		settings.load_layout(layout)


func _on_settings_toggled(is_open: bool) -> void:
	board.set_locked(is_open)
	camera_rig.paused = is_open
