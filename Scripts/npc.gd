extends CharacterBody2D

# Holds this NPC's dialog lines
var dialog_lines: Array = []

# Called when the NPC node is added to the scene
func _ready() -> void:
	# Use this node's name to fetch its dialog
	var npc_name = name
	dialog_lines = DialogDatabase.get_dialog(npc_name)
