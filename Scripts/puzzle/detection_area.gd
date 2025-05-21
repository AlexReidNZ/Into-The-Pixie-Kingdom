extends Area2D

@onready var indicator = $".."

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	indicator.visible = true
	
func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return
	indicator.visible = false
