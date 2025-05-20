extends Control

func _ready():
	hide()  

func resume():
	get_tree().paused = false
	hide()

func _on_resume_pressed():
	resume()
