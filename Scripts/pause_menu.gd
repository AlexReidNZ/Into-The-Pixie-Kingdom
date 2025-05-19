extends Control

@export var game_end_trigger: Area2D
@onready var game_end_text: Label = $GameEnd
@onready var play_button: Button = $Resume

func _ready():
	pause()
	game_end_trigger.body_entered.connect(_on_game_end_trigger_area_entered)

func resume():
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	show()

func _input(event : InputEvent):
	if event.is_action_pressed("pause") and !get_tree().paused:
		print("esc pressed")
		pause()
	elif event.is_action_pressed("pause") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_game_end_trigger_area_entered(body):
	if body.name == "Player":
		game_end_text.visible = true
		play_button.visible = false
		pause()
	
