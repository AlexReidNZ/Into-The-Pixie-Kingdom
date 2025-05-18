extends Node
class_name PlayerAudio


@export var jump_sample_1: AudioStream
@export var jump_sample_2: AudioStream
@export_range(0, 1, 0.01) var jump_2_threshold := 0.3

@onready var jump: AudioStreamPlayer = $Jump
@onready var walk: AudioStreamPlayer = $Walk


func play_jump(strength: float) -> void:
	set_jump_sample(strength)
	jump.play()

  
func set_jump_sample(strength: float) -> void:
	if strength > jump_2_threshold:
		jump.stream = jump_sample_2
		return
	jump.stream = jump_sample_1


func play_walk() -> void:
	walk.play()
