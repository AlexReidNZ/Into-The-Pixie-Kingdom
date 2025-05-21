extends Control

@onready var cutscene_controller: CutsceneController = %CutsceneController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	hide()
	if !cutscene_controller.has_started_cutscene:
		cutscene_controller.play_opening_cutscene()


func _on_button_3_pressed() -> void:
	pass # Replace with function body.


func _on_button_2_pressed() -> void:
	pass # Replace with function body.
