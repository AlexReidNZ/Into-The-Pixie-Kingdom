extends Node
class_name CutsceneController

@export var left_boundary: StaticBody2D
@export var lamina: CharacterBody2D
@export var hedera: CharacterBody2D

var has_started_cutscene := false

@onready var player: Player = %Player
@onready var camera: Camera2D = %Player/Camera2D
	
	
func play_opening_cutscene() -> void:
	# initialize
	has_started_cutscene = true
	player.move_state = Player.MoveState.CUTSCENE
	
	# walk on screen
	tween(camera, "zoom", Vector2(3, 3), 6)
	await get_tree().create_timer(1).timeout
	await player_walk_to_position_x(190, 50)
	
	# lamina calls out from nowhere
	
	await get_tree().create_timer(1.5).timeout
	# player turns around
	player.animator.scale.x = -1
	await get_tree().create_timer(1.75).timeout
	player.animator.scale.x = 1
	
	player.animator.play("look_around")
	await player.animator.animation_looped
	
	await player_walk_to_position_x(235, 15)
	
	
func player_walk_to_position_x(x: float, speed: float) -> void:
	var direction = x- player.global_position.x
	direction /= abs(direction)
	player.animator.scale.x = direction
	player.animator.play("walk")
	
	while abs(player.global_position.x - x) > 1:
		player.velocity.x = speed * direction
		print(player.global_position.x)
		await get_tree().process_frame
		
	player.velocity.x = 0
	player.animator.play("idle")


func tween(object: Object, property: NodePath, final_val: Variant, duration: float) -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property(object, property, final_val, duration).finished
