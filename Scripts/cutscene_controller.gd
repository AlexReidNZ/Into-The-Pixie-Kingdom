extends Node
class_name CutsceneController


@export var left_boundary: StaticBody2D
@export var lamina: NPC
@export var hedera: NPC
@export var mystery_speaker: Node2D

var has_started_cutscene := false
var dialog_state: DialogState

@onready var player: Player = %Player
@onready var camera: Camera2D = %Player/Camera2D
	
	
func play_opening_cutscene() -> void:
	# initialize
	has_started_cutscene = true
	player.move_state = Player.MoveState.CUTSCENE
	dialog_state = DialogStateMachineAuto.dialog_state
	lamina.visible = false
	hedera.visible = false
	mystery_speaker.global_position = Vector2(260, 260)
	
	# walk on screen
	tween_property(camera, "zoom", Vector2(3, 3), 6)
	await get_tree().create_timer(1).timeout
	await player_walk_to_position_x(190, 50)
	left_boundary.global_position.x = 0
	
	# lamina calls out from nowhere
	DialogStateMachineAuto.offer_dialog([
		{"speaker": "MysterySpeaker", "line": "Miss!"},
	])
	dialog_state.tail_sprite.visible = false
	await dialog_state.dialogue_finished
	
	# player turns around
	player.animator.scale.x = -1
	await get_tree().create_timer(1.5).timeout
	player.animator.scale.x = 1
	await get_tree().create_timer(0.75).timeout

	# lamina still trying to get attention
	DialogStateMachineAuto.offer_dialog([
		{"speaker": "MysterySpeaker", "line": "Excuse me! Miss!!"},
		{"speaker": "MysterySpeaker", "line": "Can you hear us young lady?"},
	])
	dialog_state.tail_sprite.visible = false
	await dialog_state.dialogue_finished
	
	# player confusion
	player.animator.play("look_around")
	await player.animator.animation_looped	
	await player_walk_to_position_x(235, 15)
	await get_tree().create_timer(1).timeout
	DialogStateMachineAuto.offer_dialog([
		{"speaker": "Player", "line": "...?"},
	])
	await dialog_state.dialogue_finished

	# Hadera saves us from confusion
	mystery_speaker.global_position.x += 45
	await get_tree().create_timer(0.5).timeout
	DialogStateMachineAuto.offer_dialog([
		{"speaker": "MysterySpeaker", "line": "Over here!"},
	])
	dialog_state.tail_sprite.visible = false
	await dialog_state.dialogue_finished

	# Pixies fly in


	
func player_walk_to_position_x(x: float, speed: float) -> void:
	var direction = x- player.global_position.x
	direction /= abs(direction)
	player.animator.scale.x = direction
	player.animator.play("walk")
	
	while abs(player.global_position.x - x) > 1:
		player.velocity.x = speed * direction
		await get_tree().process_frame
		
	player.velocity.x = 0
	player.animator.play("idle")


func tween_property(object: Object, property: NodePath, final_val: Variant, duration: float) -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	await tween.tween_property(object, property, final_val, duration).finished
