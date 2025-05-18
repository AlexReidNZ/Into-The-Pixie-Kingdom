extends Node
class_name UIAudio


@onready var audio_select: AudioStreamPlayer = $Select
@onready var audio_click: AudioStreamPlayer = $Click


func play_button_hover() -> void:
	audio_click.play()
	

func play_button_click() -> void:
	audio_select.play()
