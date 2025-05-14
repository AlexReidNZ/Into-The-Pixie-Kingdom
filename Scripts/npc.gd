extends CharacterBody2D

@export var sprite: Texture
@onready var sprite_2d: Sprite2D = $Sprite2D

# Holds this NPC's dialog lines
var dialog_lines: Array = []

# Called when the NPC node is added to the scene
func _ready() -> void:
	# Use this node's name to fetch its dialog
	var npc_name = name
	sprite_2d.texture = sprite
	dialog_lines = DialogDatabase.get_dialog(npc_name)
