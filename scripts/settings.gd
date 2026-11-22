extends Control

signal setup_layout(layout: Dictionary)
signal save_game(filename: String)
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
@export var setup_button: Button

@export var game_name: LineEdit
@export var save_button: Button


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

	setup_button.pressed.connect(_on_setup_layout_pressed)
	save_button.pressed.connect(_save_game_pressed)
	save_button.disabled = true
	game_name.text_changed.connect(_game_name_text_changed)


func load_layout(layout: Dictionary) -> void:
	setup_grid.apply_layout(layout)


func _on_setup_layout_pressed() -> void:
	setup_layout.emit(setup_grid.get_layout())


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
