extends Node

# Holds all dialog loaded from the JSON file
var dialog_data: Dictionary = {}

func _ready() -> void:
	# Path to the dialog JSON file
	var path: String = "res://data/DialogDatabase.json"

	# Check if file exists
	if not FileAccess.file_exists(path):
		push_error("Dialogue JSON not found at %s" % path)
		return

	# Open file for reading
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open %s" % path)
		return

	# Parse JSON into a Dictionary
	var result = JSON.parse_string(file.get_as_text())
	if result is Dictionary:
		dialog_data = result
	else:
		push_error("Dialogue JSON format is invalid (expected a Dictionary at the root).")

# Get the dialog lines for a specific NPC ID
func get_dialog(npc_id: String) -> Array:
	return dialog_data.get(npc_id, [])
