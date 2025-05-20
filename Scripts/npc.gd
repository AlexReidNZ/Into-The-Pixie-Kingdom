extends CharacterBody2D

@export var sprite: Texture
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var dialogue_audio: AudioStream

# Holds this NPC's dialog lines
var dialog_lines: Array = []
var has_spoken: bool = false

# Called when the NPC node is added to the scene
func _ready() -> void:
	# Use this node's name to fetch its dialog
	var npc_name = name
	sprite_2d.texture = sprite
	dialog_lines = DialogDatabase.get_dialog(npc_name)
	(get_node("Audio/Dialogue") as AudioStreamPlayer).stream = dialogue_audio

func _on_interact():
	if has_spoken:
		show_generic_dialog()
	else:
		if DialogStateMachineAuto:
			DialogStateMachineAuto.offer_dialog(dialog_lines)
			has_spoken = true

func dialog_finished():
	has_spoken = true

func show_generic_dialog():
	if DialogStateMachineAuto:
		DialogStateMachineAuto.offer_dialog([
			{"speaker": name, "line": "I have nothing more to say."}
		])
