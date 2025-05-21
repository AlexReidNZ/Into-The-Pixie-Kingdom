extends Area2D

@onready var indicator = $".."
var player_in_area = false

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	indicator.visible = true
	player_in_area = true
	
func _on_body_exited(body: Node2D) -> void:
	if body.name != "Player":
		return
	indicator.visible = false
	player_in_area = false
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("open_puzzle") && player_in_area:
		indicator.toggle_puzzle()
