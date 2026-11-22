class_name CameraRig
extends Node3D

const MIN_ZOOM := 2.5
const MAX_ZOOM := 8.5
const ZOOM_STEP := 1.5
const ROTATE_SENSITIVITY := 0.004

@onready var cam: Camera3D = $Camera3D

var paused := false
var rotating := false
var cam_zpos := 7.0:
	set(value):
		cam_zpos = clampf(value, MIN_ZOOM, MAX_ZOOM)


func _process(delta: float) -> void:
	cam.position.z = lerp(cam.position.z, cam_zpos, 0.2)
	if paused:
		return
	var direction := Input.get_vector("left", "right", "up", "down")
	rotation.y += direction.x * delta
	rotation.x += direction.y * delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		rotating = true
	elif event.is_action_released("move"):
		rotating = false

	if event is InputEventMouseMotion and rotating:
		rotation.y += -event.relative.x * ROTATE_SENSITIVITY
		rotation.x += -event.relative.y * ROTATE_SENSITIVITY

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_zpos -= ZOOM_STEP
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_zpos += ZOOM_STEP
