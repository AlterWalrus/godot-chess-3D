class_name Square
extends Area3D

var coords: Vector2
var color: Color
var mouse_in := false

@onready var plane := $MeshInstance3D


func _ready() -> void:
	plane.mesh = PlaneMesh.new()
	plane.mesh.size = Vector2.ONE * 0.95
	
	plane.mesh.material = StandardMaterial3D.new()
	plane.mesh.material.albedo_color = color


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and mouse_in:
			print(coords)


func _mouse_enter() -> void:
	mouse_in = true
	plane.mesh.material.albedo_color = Color.DIM_GRAY


func _mouse_exit() -> void:
	mouse_in = false
	plane.mesh.material.albedo_color = color
