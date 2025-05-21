extends Node


var tween: Tween

@onready var player: Player = %Player
@onready var camera: Camera2D = %Player/Camera2D


func _ready() -> void:
	play_opening_cutscene()
	
	
func play_opening_cutscene() -> void:
	camera.zoom = Vector2(3.5, 3.5)
	player.move_state = Player.MoveState.CUTSCENE
	player.animator.play("walk")
	await player_walk_to_position_x(240)
	#tween.tween_property(player, "global_position.x", 250, 15)
	
	
func player_walk_to_position_x(x: float) -> void:
	var direction = x- player.global_position.x
	direction /= abs(direction)
	while abs(player.global_position.x - x) > 1:
		player.velocity.x = player.speed * direction
		#player.move_and_slide()
		#print("walking?")
		await get_tree().process_frame
		

func reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
