extends Node

var dialog_data = {}

func _ready():
	var file = FileAccess.open("res://data/DialogDatabase.json", FileAccess.READ)
	if file: 
		dialog_data = JSON.parse_string(file.get_as_text()) or {}

func get_dialog(npc_id: String) -> Array:
	return dialog_data.get(npc_id, ["..."])
