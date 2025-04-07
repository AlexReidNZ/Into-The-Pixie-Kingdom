# Player.gd
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction != Vector2.ZERO:	
		direction = direction.normalized()
	
	velocity = direction * SPEED

	move_and_slide()
