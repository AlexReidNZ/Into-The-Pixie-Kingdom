extends CharacterBody2D


enum MoveState {
	IDLE,
	WALKING,
	RUNNING,
	JUMPING,
	FALLING,
}

const animations := {
	MoveState.IDLE: "idle",
	MoveState.WALKING: "walk",
	MoveState.RUNNING: "run",
	MoveState.JUMPING: "jump",
	MoveState.FALLING: "fall",
}

## Walking rate in pixels per second
@export_range(1, 300) var speed := 100
@export_range(1, 2, 0.01) var run_speed_multiplier := 1.69
@export_range(0, 1, 0.01) var acceleration := 0.5
@export_range(0, 1, 0.01) var deceleration := 0.5
@export_range(100, 500) var jump_velocity := 250

## Time (in milliseconds) the player can press jump before/after touching the ground.
## Named after Wile E. Coyote from Looney Tunes, may he rest in peace. <3
@export_range(0, 250, 5) var coyote_time_ms := 100

var last_jump_input_time_ms := -1
var last_on_floor_time_ms := -1
var jump_queued := false
var move_state := MoveState.IDLE:
	set = set_move_state

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta: float) -> void:
	calculate_velocity_x(delta)
	calculate_velocity_y(delta)

	if jump_queued:
		try_jump()

	move_and_slide()
	
	
func calculate_velocity_x(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
		if direction:
		var move_speed := speed
		if Input.get_action_strength("run"):
			move_state = MoveState.RUNNING
move_speed *= run_speed_multiplier
		else:
			move_state = MoveState.WALKING
velocity.x = move_toward(velocity.x, direction * move_speed, speed * acceleration)
		# keep sprite facing towards movement direction
		animator.scale.x = roundi(direction)
	else:
		# deceleration by speed
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
		if not velocity.x:
			move_state = MoveState.IDLE


func calculate_velocity_y(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:
			move_state = MoveState.JUMPING
		else:
			move_state = MoveState.FALLING
	else:
		last_on_floor_time_ms = Time.get_ticks_msec()
			

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		queue_jump()			
		
		
func queue_jump() -> void:
	last_jump_input_time_ms = Time.get_ticks_msec()
	jump_queued = true
	

func try_jump() -> void:
	# been too long since player input
	if Time.get_ticks_msec() > last_jump_input_time_ms + coyote_time_ms:
		jump_queued = false
		return
	# been too long since player was touching the floor
	if Time.get_ticks_msec() > last_on_floor_time_ms + coyote_time_ms:
		# jump can stay queued in this case
		return
		
	jump_queued = false
	last_on_floor_time_ms = -1
	# Negative Y direction is upwards in 2D space
	velocity.y = -jump_velocity
				

func set_move_state(value: MoveState) -> void:
	# only process when move_state changes to a new state
	if move_state == value:
		return
	move_state = value
	animator.play(animations[move_state])
