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

## How long to hold jump button to get max height jump
@export_range(0, 3, 0.025) var jump_anticipation_max_time_sec := 1.0

## Multiplier of jump height at maximum anticipation time
@export_range(1, 5, 0.025) var jump_anticipation_multiplier := 2.0

## Time (in milliseconds) the player can press jump before/after touching the ground.
## Named after Wile E. Coyote from Looney Tunes, may he rest in peace. <3
@export_range(0, 250, 5) var coyote_time_ms := 100

## Chance to play "look around" animation when idle
@export_range(0, 1, 0.05) var animate_look_around_chance := 0.2

## Indexes of walk animation frames where foot touches the ground
@export var walk_step_frames: Array[int]

var last_jump_input_time_ms := -1
var last_on_floor_time_ms := -1
var jump_anticipation_time := 0.0
var anticipation_amount := 0.0
var jump_queued := false
var shush := false
var move_state := MoveState.IDLE:
	set = set_move_state

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio: PlayerAudio = $Audio


func _process(delta: float) -> void:
	calculate_velocity_x(delta)
	calculate_velocity_y(delta)
	
	if move_state == MoveState.JUMP_ANTICIPATING:
		jump_anticipation_time = clampf(
				jump_anticipation_time + delta,
				0, 
				jump_anticipation_max_time_sec)
		anticipation_amount = inverse_lerp(
				0,       
				jump_anticipation_max_time_sec, 
				jump_anticipation_time)  
	else:
		jump_anticipation_time = 0
		anticipation_amount = 0

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
		
		
func _on_animation_frame_changed() -> void:
	if move_state not in [MoveState.WALKING, MoveState.RUNNING]:
		return
	if shush:
		return
	# play walk sounds when foot touches ground
	if animator.frame in walk_step_frames:
		audio.play_walk()
	
	
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
		move_speed *= 1 - anticipation_amount
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
		if Input.is_action_pressed("jump") and move_state != MoveState.JUMP_ANTICIPATING:
			move_state = MoveState.JUMP_ANTICIPATING
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
	var anticipation_multiplier = lerpf(1, jump_anticipation_multiplier, anticipation_amount)
	velocity.y = -jump_velocity * anticipation_multiplier
	audio.play_jump(anticipation_amount)
	

func set_move_state(value: MoveState) -> void:
	# only process when move_state changes to a new state
	if move_state == value:
		return
		
	# running and walking is the same animation, so try keep same animation going
	var continue_animation := false
	var continued_animation_frame = animator.frame
	
	# some states can only path to certain other states
	match move_state:
		MoveState.JUMP_ANTICIPATING:
			if value not in [MoveState.JUMPING, MoveState.FALLING, MoveState.PAUSED]:
				return
		MoveState.RUNNING:
			if value == MoveState.WALKING:
				continue_animation = true
		MoveState.WALKING:
			if value == MoveState.RUNNING:
				continue_animation = true
		MoveState.PAUSED:
			if value != MoveState.IDLE:
				return
	
	move_state = value
	shush = continue_animation
	animator.play(animations[move_state])
	shush = false
	if continue_animation:
		animator.frame = continued_animation_frame

	
