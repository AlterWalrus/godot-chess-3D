extends GridContainer
class_name SetupGrid

@export var popup: PopupMenu
@export var layout_button_scene: PackedScene
@export var reset_button: Button

signal piece_changed(coords: Vector2i, piece: int, is_white: bool)
signal cleared

var hover_button: LayoutButton
var active_button: LayoutButton

func _ready() -> void:
	reset_button.pressed.connect(_on_reset_pressed)
	popup.index_pressed.connect(_piece_changed)
	for i in range(64):
		var button: LayoutButton = layout_button_scene.instantiate()
		@warning_ignore("integer_division")
		button.get_node("TextureRect").modulate = Color.WHITE if (i % 8 + i / 8) % 2 == 0 else Color.BLACK
		@warning_ignore("integer_division")
		_setup_button(button, Vector2i(i % 8, i / 8))
		add_child(button)


func _setup_button(button: LayoutButton, coords: Vector2i) -> void:
	button.pressed.connect(_button_pressed.bind(button))
	button.mouse_entered.connect(_button_mouse_entered.bind(button))
	button.coords = coords


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		return
	if hover_button == null:
		return
	hover_button.switch_color()
	if hover_button.piece != 0:
		piece_changed.emit(hover_button.coords, hover_button.piece, hover_button.is_white)


func _button_pressed(button: LayoutButton) -> void:
	active_button = button
	popup.show()
	var offset := Vector2.ZERO
	var space := get_viewport_rect().size.y - button.global_position.y
	if space < popup.size.y:
		offset.y -= popup.size.y - space
	popup.position = button.global_position + offset


func _button_mouse_entered(button: LayoutButton) -> void:
	hover_button = button


func _piece_changed(index: int) -> void:
	if active_button == null:
		return
	active_button.piece = index
	active_button.icon = popup.get_item_icon(index)
	piece_changed.emit(active_button.coords, index, active_button.is_white)


func apply_layout(layout: Dictionary) -> void:
	_clear_buttons()
	for coords in layout.keys():
		var button := _find_button(coords)
		if button == null:
			continue
		button.piece = layout[coords].piece
		button.icon = popup.get_item_icon(button.piece)
		button.set_color(layout[coords].is_white)


func set_piece(coords: Vector2i, piece: int, is_white: bool) -> void:
	var button := _find_button(coords)
	if button == null:
		return
	button.piece = piece
	button.icon = popup.get_item_icon(piece)
	button.set_color(is_white)


func _on_reset_pressed() -> void:
	_clear_buttons()
	cleared.emit()


func _clear_buttons() -> void:
	for child in get_children():
		if child is LayoutButton:
			child.piece = 0
			child.icon = null
			child.set_color(true)


func _find_button(coords: Vector2i) -> LayoutButton:
	for child in get_children():
		if child is LayoutButton and child.coords == coords:
			return child
	return null
