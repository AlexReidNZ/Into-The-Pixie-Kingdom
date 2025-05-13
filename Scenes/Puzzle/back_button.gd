extends Area2D

var clickable = false
@onready var puzzle_indicator = $"../../.."

func _process(delta: float) -> void:
	if clickable and Input.is_action_just_pressed("click"):
		puzzle_indicator.toggle_puzzle()

func _on_mouse_entered() -> void:
	clickable = true
	scale = Vector2(1.1,1.1)

func _on_mouse_exited() -> void:
	clickable = false
	scale = Vector2(1,1)
