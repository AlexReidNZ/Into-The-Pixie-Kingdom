extends Control

func _ready():
	pause()

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
