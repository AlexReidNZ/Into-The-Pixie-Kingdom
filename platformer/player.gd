extends CharacterBody2D
class_name Player

enum MoveState {
	IDLE,
	WALKING,
	RUNNING,
	JUMP_ANTICIPATING,
	JUMPING,
	FALLING,
	LANDING,
	PAUSED,
}

const animations := {
	MoveState.IDLE: "idle",
	MoveState.WALKING: "walk",
	MoveState.RUNNING: "run",
	MoveState.JUMP_ANTICIPATING: "jump_anticipate",
	MoveState.JUMPING: "jump",
	MoveState.FALLING: "fall",
	MoveState.LANDING: "land",
	MoveState.PAUSED: "paused",
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

## Chance to play "look around" animation when idle
@export_range(0, 1, 0.05) var animate_look_around_chance := 0.2

var last_jump_input_time_ms := -1
var last_on_floor_time_ms := -1
var jump_queued := false
var move_state := MoveState.IDLE:
	set = set_move_state

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: PlayerAudio = $Audio


func _process(delta: float) -> void:
	calculate_velocity_x(delta)
	calculate_velocity_y(delta)

	if jump_queued:
		try_jump()

	move_and_slide()
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		move_state = MoveState.JUMP_ANTICIPATING
	if event.is_action_released("jump"):
		queue_jump()

	
func _on_animation_looped() -> void:
	if move_state == MoveState.IDLE:
		if randf() <= animate_look_around_chance:
			animator.play("look_around")
		else:
			animator.play("idle")


func _on_animation_finished() -> void:
	if move_state == MoveState.LANDING:
		move_state = MoveState.IDLE
	
	
func calculate_velocity_x(delta: float) -> void:
	if move_state == MoveState.PAUSED:
		velocity.x = 0
		return
	var direction := Input.get_axis("move_left", "move_right")
	if move_state == MoveState.LANDING:
		direction = 0
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
		if is_on_floor() and move_state != MoveState.LANDING:
			move_state = MoveState.IDLE


func calculate_velocity_y(delta: float) -> void:
	if is_on_floor() and move_state != MoveState.PAUSED:
		if move_state == MoveState.JUMPING or move_state == MoveState.FALLING:
			move_state = MoveState.LANDING
		last_on_floor_time_ms = Time.get_ticks_msec()
		return
	
	velocity += get_gravity() * delta
	
	if move_state == MoveState.PAUSED:
		return
	
	if velocity.y < 0:
		move_state = MoveState.JUMPING
	else:
		move_state = MoveState.FALLING
		
		
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
	
	jump()
	
	
func jump() -> void:
	jump_queued = false
	last_on_floor_time_ms = -1
	# Negative Y direction is upwards in 2D space
	velocity.y = -jump_velocity
	audio.play_jump(1)
	

func set_move_state(value: MoveState) -> void:
	# only process when move_state changes to a new state
	if move_state == value:
		return
	
	# some states can only path to certain other states
	match move_state:
		MoveState.JUMP_ANTICIPATING:
			if value not in [MoveState.JUMPING, MoveState.FALLING]:
				return
		MoveState.PAUSED:
			if value != MoveState.IDLE:
				return
	
	move_state = value
	animator.play(animations[move_state])
	print(animations[move_state])
