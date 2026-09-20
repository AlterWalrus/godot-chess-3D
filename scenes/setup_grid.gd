extends GridContainer

@export var popup: PopupMenu

var active_button: Button = null

@onready var button_sample: Button = $PieceButton

func _ready() -> void:
	popup.index_pressed.connect(_piece_changed)
	
	_setup_button(button_sample)
	for i in range(1, 64):
		var btn = button_sample.duplicate()
		var w = !(int(i/8)+i)&1
		btn.get_node("TextureRect").modulate = Color.WHITE if w else Color.BLACK
		_setup_button(btn)
		add_child(btn)


func _setup_button(btn: Button) -> void:
	btn.pressed.connect(_button_pressed.bind(btn))


func _button_pressed(btn: Button) -> void:
	active_button = btn
	popup.show()
	popup.position = btn.global_position


func _piece_changed(index: int) -> void:
	if active_button:
		active_button.icon = popup.get_item_icon(index)
