extends Node
class_name PuzzleAudio


@onready var place_block: AudioStreamPlayer = $PlaceBlock
@onready var pickup_block: AudioStreamPlayer = $PickupBlock
@onready var win: AudioStreamPlayer = $Win


func play_place_block() -> void:
	place_block.play()


func play_pickup_block() -> void:
	pickup_block.play()


func play_win() -> void:
	win.play()
