extends CharacterBody2D


@export_range(1, 300) var speed = 100.0
@export_range(0, 1) var deceleration = 0.5
@export_range(1, 2) var run_speed_multiplier = 1.69
@export_range(1, 300) var jump_velocity = 200.0

## Time (in milliseconds) the player can press jump before/after touching the ground.
## Named after Wile E. Coyote from Looney Tunes, may he rest in peace. <3
@export_range(0, 250, 5) var coyote_time_ms := 100

var last_jump_input_time_ms := -1
var last_on_floor_time_ms := -1
var jump_queued := false

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		last_on_floor_time_ms = Time.get_ticks_msec()

	if jump_queued:
		try_jump()

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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		queue_jump()
		
		
func queue_jump() -> void:
	last_jump_input_time_ms = Time.get_ticks_msec()
	jump_queued = true
	

func try_jump() -> void:
	if (Time.get_ticks_msec() < last_on_floor_time_ms + coyote_time_ms 
			and Time.get_ticks_msec() < last_jump_input_time_ms + coyote_time_ms):
		jump_queued = false
		last_on_floor_time_ms = -1
		# Negative Y direction is upwards in 2D space
		velocity.y = -jump_velocity
		
