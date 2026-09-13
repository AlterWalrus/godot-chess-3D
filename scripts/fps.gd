extends Label

@onready var timer := $Timer

func _ready() -> void:
	timer.timeout.connect(_update)


func _update():
	text = str(int(Engine.get_frames_per_second())) + " FPS"
