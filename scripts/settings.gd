extends Control

signal setup_layout(layout: Dictionary)
signal save_game

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
@export var backgrond: OptionButton

@export var setup_grid: GridContainer
@export var setup_button: Button

@export var game_name: LineEdit
@export var save_button: Button

func _ready() -> void:
	for c in settings_vbox.get_children():
		if c is Control:
			c.focus_mode = Control.FOCUS_NONE
	
	settings_panel.hide()
	settings_button.pressed.connect(_on_settings_pressed)
	fullscreen.toggled.connect(_fullscreen_toggle)
	shadows.toggled.connect(_shadows_toggle)
	ssao.toggled.connect(_ssao_toggled)
	glow.toggled.connect(_glow_toggled)
	depth.toggled.connect(_depth_toggled)
	backgrond.item_selected.connect(_background_changed)
	
	setup_button.pressed.connect(setup_layout.emit.bind(setup_grid.layout))
	save_button.pressed.connect(save_game.emit)
	save_button.disabled = true
	game_name.text_changed.connect(_game_name_text_changed)


func _game_name_text_changed(new_string: String):
	save_button.disabled = new_string.is_empty()


func _background_changed(index):
	if not background_list[index]:
		env.environment.background_mode = Environment.BG_CLEAR_COLOR
		return
	
	env.environment.background_mode = Environment.BG_SKY
	env.environment.sky = background_list[index]


func _depth_toggled(on):
	env.camera_attributes.dof_blur_far_enabled = on


func _glow_toggled(on):
	env.environment.glow_enabled = on


func _ssao_toggled(on):
	env.environment.ssao_enabled = on


func _shadows_toggle(on):
	sun.shadow_enabled = on


func _fullscreen_toggle(fs):
	var ds := DisplayServer
	ds.window_set_mode(ds.WINDOW_MODE_FULLSCREEN if fs else ds.WINDOW_MODE_WINDOWED)


func _on_settings_pressed():
	settings_open = not settings_open
	settings_button.disabled = true
	settings_panel.show()
	
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	if settings_open:
		t.tween_property(settings_panel, "position:x", og_pos.x, 0.2).from(1280)
	else:
		t.tween_property(settings_panel, "position:x", 1280, 0.2).from(og_pos.x)
	
	await t.finished
	settings_button.disabled = false
	if not settings_open:
		settings_panel.hide()
