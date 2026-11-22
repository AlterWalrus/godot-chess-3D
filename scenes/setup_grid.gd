extends GridContainer

signal layout_changed(layout: Dictionary)

@export var popup: PopupMenu
@export var layout_button_scene: PackedScene

var hover_button: LayoutButton = null
var active_button: LayoutButton = null

func _ready() -> void:
	popup.index_pressed.connect(_piece_changed)
	
	for i in range(64):
		var btn: LayoutButton = layout_button_scene.instantiate()
		var col: Color = Color.WHITE if !(int(i/8.0)+i)&1 else Color.BLACK
		btn.get_node("TextureRect").modulate = col
		_setup_button(btn, Vector2i(i%8, int(i/8.0)))
		add_child(btn)


func _setup_button(btn: LayoutButton, c: Vector2i) -> void:
	btn.pressed.connect(_button_pressed.bind(btn))
	btn.mouse_entered.connect(_button_mouse_entered.bind(btn))
	btn.coords = c


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_RIGHT or not event.pressed:
			return
		if not hover_button:
			return
		
		hover_button.switch_color()
		layout_changed.emit(get_layout())


func _button_pressed(btn: LayoutButton) -> void:
	active_button = btn
	popup.show()
	
	var offset = Vector2.ZERO
	var space = get_viewport_rect().size.y - btn.global_position.y
	if space < popup.size.y:
		offset.y -= popup.size.y-space
	popup.position = btn.global_position + offset


func _button_mouse_entered(btn: LayoutButton):
	hover_button = btn


func _piece_changed(index: int) -> void:
	if not active_button:
		return
	active_button.piece = index
	active_button.icon = popup.get_item_icon(index)
	layout_changed.emit(get_layout())


func get_layout() -> Dictionary:
	var layout: Dictionary = {}
	for btn in get_children():
		if btn is LayoutButton and btn.piece != 0:
			layout[btn.coords] = {
				"piece": btn.piece,
				"is_white": btn.is_white
			}
	return layout


func apply_layout(layout: Dictionary) -> void:
	_clear_buttons()
	for pos in layout.keys():
		var btn := _find_button(pos)
		if btn == null:
			continue
		btn.piece = layout[pos].piece
		btn.icon = popup.get_item_icon(btn.piece)
		btn.set_color(layout[pos].is_white)


func _clear_buttons() -> void:
	for btn in get_children():
		if btn is LayoutButton:
			btn.piece = 0
			btn.icon = null
			btn.set_color(true)


func _find_button(coords: Vector2i) -> LayoutButton:
	for btn in get_children():
		if btn is LayoutButton and btn.coords == coords:
			return btn
	return null
