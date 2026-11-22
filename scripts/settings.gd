class_name Settings
extends Control

signal piece_changed(coords: Vector2i, piece: int, is_white: bool)
signal reset_layout()
signal restore_default()
signal save_game(filename: String)
signal load_game(filename: String)
signal toggled(is_open: bool)

var settings_open := false
var og_pos := Vector2(888, 0)

@export var env: WorldEnvironment
@export var sun: DirectionalLight3D
@export var background_list: Array[Sky]

@export var settings_button: Button
@export var settings_panel: Panel

@export var settings_vbox: VBoxContainer
@export var fullscreen: CheckButton
@export var shadows: CheckButton
@export var ssao: CheckButton
@export var glow: CheckButton
@export var depth: CheckButton
@export var background: OptionButton

@export var setup_grid: SetupGrid
@export var restore_button: Button

@export var game_name: LineEdit
@export var save_button: Button
@export var load_button: MenuButton
@export var save_notification: AcceptDialog


func _ready() -> void:
	for child in settings_vbox.get_children():
		if child is Control:
			child.focus_mode = Control.FOCUS_NONE

	settings_panel.hide()
	settings_button.pressed.connect(_on_settings_pressed)
	fullscreen.toggled.connect(_fullscreen_toggled)
	shadows.toggled.connect(_shadows_toggled)
	ssao.toggled.connect(_ssao_toggled)
	glow.toggled.connect(_glow_toggled)
	depth.toggled.connect(_depth_toggled)
	background.item_selected.connect(_background_changed)

	setup_grid.piece_changed.connect(piece_changed.emit)
	setup_grid.cleared.connect(reset_layout.emit)
	restore_button.pressed.connect(_on_restore_default_pressed)
	save_button.pressed.connect(_save_game_pressed)
	save_button.disabled = true
	game_name.text_changed.connect(_game_name_text_changed)
	load_button.get_popup().about_to_popup.connect(_populate_load_menu)
	load_button.get_popup().index_pressed.connect(_on_load_selected)
	
	load_button.disabled = Board.list_saves().is_empty()


func load_layout(layout: Dictionary) -> void:
	setup_grid.apply_layout(layout)


func set_piece(coords: Vector2i, piece: int, is_white: bool) -> void:
	setup_grid.set_piece(coords, piece, is_white)


func _on_restore_default_pressed() -> void:
	restore_default.emit()


func _game_name_text_changed(text: String) -> void:
	save_button.disabled = text.is_empty()


func _background_changed(index: int) -> void:
	if not background_list[index]:
		env.environment.background_mode = Environment.BG_CLEAR_COLOR
		return
	env.environment.background_mode = Environment.BG_SKY
	env.environment.sky = background_list[index]


func _depth_toggled(on: bool) -> void:
	env.camera_attributes.dof_blur_far_enabled = on


func _glow_toggled(on: bool) -> void:
	env.environment.glow_enabled = on


func _ssao_toggled(on: bool) -> void:
	env.environment.ssao_enabled = on


func _shadows_toggled(on: bool) -> void:
	sun.shadow_enabled = on


func _fullscreen_toggled(on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _save_game_pressed() -> void:
	save_game.emit(game_name.text)
	game_name.text = ""
	save_notification.popup_centered()
	load_button.disabled = false


func _populate_load_menu() -> void:
	var popup := load_button.get_popup()
	popup.clear()
	for filename in Board.list_saves():
		popup.add_item(filename)


func _on_load_selected(index: int) -> void:
	var filename: String = load_button.get_popup().get_item_text(index)
	load_game.emit(filename)


func _on_settings_pressed() -> void:
	settings_open = not settings_open
	settings_button.disabled = true
	settings_panel.show()
	toggled.emit(settings_open)

	var tween := create_tween().set_trans(Tween.TRANS_CUBIC)
	if settings_open:
		tween.tween_property(settings_panel, "position:x", og_pos.x, 0.2).from(1280)
	else:
		tween.tween_property(settings_panel, "position:x", 1280, 0.2).from(og_pos.x)

	await tween.finished
	settings_button.disabled = false
	if not settings_open:
		settings_panel.hide()
