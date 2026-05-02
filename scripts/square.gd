class_name Square
extends Area3D

signal square_selected

var piece: Piece
var coords: Vector2
var color: Color
var mouse_in := false

@onready var model := $MeshInstance3D

func _ready() -> void:
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.95, 0.4, 0.95)
	model.mesh = mesh
	
	model.mesh.material = StandardMaterial3D.new()
	model.mesh.material.albedo_color = color


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and mouse_in:
		square_selected.emit(self, piece)


func _mouse_enter() -> void:
	mouse_in = true
	model.mesh.material.albedo_color = Color.DIM_GRAY


func _mouse_exit() -> void:
	mouse_in = false
	model.mesh.material.albedo_color = color
