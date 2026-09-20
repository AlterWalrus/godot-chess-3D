extends GridContainer

@export var popup: PopupMenu

@onready var button_sample: Button = $PieceButton

func _ready() -> void:
	popup.index_pressed.connect(_piece_changed)
	
	_setup_button(button_sample)
	for i in range(63):
		var btn = button_sample.duplicate()
		_setup_button(btn)
		add_child(btn)


func _setup_button(btn: Button) -> void:
	btn.pressed.connect(_button_pressed.bind(btn))
	


func _button_pressed(btn: Button) -> void:
	popup.show()
	popup.position = btn.global_position


func _piece_changed(index: int) -> void:
	print(popup.get_item_icon(index))
