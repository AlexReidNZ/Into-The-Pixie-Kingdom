extends BaseState
class_name IdleState

# Called when entering the Idle state
func enter(data = null) -> void:
	# Re-enable player movement and input
	if state_machine.player_node:
		state_machine.player_node.set_physics_process(true)
		state_machine.player_node.set_process_input(true)

# Called when dialog is offered while idle
func offer_dialog(lines: Array) -> void:
	# Start dialog if lines are available
	if lines.size() > 0:
		state_machine.change_state("Dialog", lines)

# Called if dialog is cancelled while in idle (noop here)
func cancel_dialog() -> void:
	pass
