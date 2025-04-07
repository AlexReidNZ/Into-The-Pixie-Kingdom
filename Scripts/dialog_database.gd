# DialogDatabase.gd  (autoload Singleton)
extends Node

var dialog_data: Dictionary = {}

func _ready() -> void:
	# Load dialog data from JSON at startup
	var path: String = "res://data/DialogDatabase.json"
	if not FileAccess.file_exists(path):
		push_error("Dialogue JSON not found at %s" % path)
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open %s" % path)
		return
	# Parse the JSON text into a Dictionary
	var result = JSON.parse_string(file.get_as_text())
	if result is Dictionary:
		dialog_data = result
	else:
		push_error("Dialogue JSON format is invalid (expected a Dictionary at the root).")

func get_dialog(npc_id: String) -> Array:
	return dialog_data.get(npc_id, [])
