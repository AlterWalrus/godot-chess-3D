extends Control

var settings_open := false

@export var env: WorldEnvironment

@onready var settings_button := $SettingsButton
@onready var settings_panel := $SettingsPanel

@onready var fullscreen := $SettingsPanel/Fullscreen

func _ready() -> void:
	settings_panel.hide()
	settings_button.pressed.connect(_on_settings_pressed)
	fullscreen.toggled.connect(_fullscreen_toggle)


func _fullscreen_toggle(fs):
	var ds := DisplayServer
	ds.window_set_mode(ds.WINDOW_MODE_FULLSCREEN if fs else ds.WINDOW_MODE_WINDOWED)


func _on_settings_pressed():
	settings_open = not settings_open
	settings_button.disabled = true
	settings_panel.show()
	
	var t = create_tween().set_trans(Tween.TRANS_CUBIC)
	if settings_open:
		t.tween_property(settings_panel, "scale", Vector2.ONE, 0.2).from(Vector2.ONE*0.1)
	else:
		t.tween_property(settings_panel, "scale", Vector2.ONE*0.1, 0.2).from(Vector2.ONE)
	
	await t.finished
	settings_button.disabled = false
	if not settings_open:
		settings_panel.hide()
