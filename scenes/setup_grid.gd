extends GridContainer

@export var popup: PopupMenu
@export var layout_button_scene: PackedScene

var active_button: LayoutButton = null
var layout: Dictionary = {}

func _ready() -> void:
	popup.index_pressed.connect(_piece_changed)
	
	for i in range(64):
		var btn: LayoutButton = layout_button_scene.instantiate()
		var col = Color.WHITE if !(int(i/8.0)+i)&1 else Color.BLACK
		btn.get_node("TextureRect").modulate = col
		_setup_button(btn, Vector2i(i%8, int(i/8.0)))
		add_child(btn)


func _setup_button(btn: LayoutButton, c: Vector2i) -> void:
	btn.pressed.connect(_button_pressed.bind(btn))
	btn.coords = c


func _button_pressed(btn: LayoutButton) -> void:
	active_button = btn
	popup.show()
	
	var offset = Vector2.ZERO
	var space = get_viewport_rect().size.y - btn.global_position.y
	if space < popup.size.y:
		offset.y -= popup.size.y-space
	popup.position = btn.global_position + offset


func _piece_changed(index: int) -> void:
	if active_button:
		active_button.icon = popup.get_item_icon(index)
		
		if index == 0:
			layout.erase(active_button.coords)
			return
		
		layout[active_button.coords] = {
			"piece": index,
			"is_white": active_button.is_white
		}
