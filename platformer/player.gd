extends CharacterBody2D


@export_range(1, 300) var speed = 100.0
@export_range(0, 1) var deceleration = 0.5
@export_range(1, 2) var run_speed_multiplier = 1.69
@export_range(1, 300) var jump_velocity = 200.0

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Negative Y direction is upwards in 2D space
		velocity.y = -jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	var speed_mutliplier = 1 + Input.get_action_strength("run") * run_speed_multiplier
	if direction:
		velocity.x = direction * speed * speed_mutliplier
	else:
		# Deceleration by speed
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)

	move_and_slide()
