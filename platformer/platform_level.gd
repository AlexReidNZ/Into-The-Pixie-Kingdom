extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DialogStateMachineAuto.main_node = get_tree().get_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
