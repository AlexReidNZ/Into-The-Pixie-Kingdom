extends CharacterBody2D

# Movement speed (can be set in the inspector)
@export var speed = 200.0

# Called every physics frame
func _physics_process(delta: float) -> void:
	var input_vec = Vector2.ZERO

	# Get movement input from arrow/WASD keys
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")

	# If moving, apply direction and speed
	if input_vec.length() > 0:
		velocity = input_vec.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
