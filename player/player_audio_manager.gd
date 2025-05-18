extends Node
class_name PlayerAudio


@export var jump_sample_1: AudioStream
@export var jump_sample_2: AudioStream
@export var jump_sample_3: AudioStream

@onready var jump: AudioStreamPlayer = $Jump


func play_jump(strength: float) -> void:
	jump.play()
