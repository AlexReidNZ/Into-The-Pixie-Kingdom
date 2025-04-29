extends Node
class_name BaseState

# Reference to the state machine this state belongs to
var state_machine: Node

# Called when the state becomes active
func enter(data = null) -> void:
	pass

# Called when the state is exited
func exit() -> void:
	pass

# Called every frame (if your state uses update logic)
func update(delta: float) -> void:
	pass

# Called when input is received
func handle_input(event: InputEvent) -> void:
	pass

# Called when dialog is offered to this state
func offer_dialog(lines: Array) -> void:
	pass

# Called when dialog is cancelled
func cancel_dialog() -> void:
	pass
