extends Node
class_name DialogStateMachine

# Name of the player node to look for in the scene
const PLAYER_BODY_NAME := "Player"

# Typing speed for dialog (seconds per character)
@export var text_speed: float = 0.05

# Cached references
var player_node: Node2D = null
var main_node: Node = null

# State instances
var idle_state
var dialog_state
var current_state
var states = {}

# Called when the state machine is added to the scene
func _ready() -> void:
	main_node = get_tree().get_current_scene()
	if main_node == null:
		push_error("DialogStateMachine: No current scene!")
		return

	# Find the player in the scene by name
	player_node = _find_node_recursive(main_node, PLAYER_BODY_NAME) as Node2D
	if player_node == null:
		push_error("DialogStateMachine: Can't find Node2D named '%s'." % PLAYER_BODY_NAME)

	# Load states and assign this machine to them
	idle_state = preload("res://Scripts/states/idle_state.gd").new()
	dialog_state = preload("res://Scripts/states/dialog_state.gd").new()

	for state in [idle_state, dialog_state]:
		state.state_machine = self

	states["Idle"] = idle_state
	states["Dialog"] = dialog_state

	# Start in Idle state
	current_state = idle_state
	current_state.enter()

# Switch to another state
func change_state(state_name: String, data = null) -> void:
	if not states.has(state_name):
		push_error("DialogStateMachine: Unknown state '%s'" % state_name)
		return

	if current_state:
		current_state.exit()

	current_state = states[state_name]
	current_state.enter(data)

# Forward dialog offer to current state
func offer_dialog(lines: Array) -> void:
	if current_state:
		current_state.offer_dialog(lines)

# Forward dialog cancel to current state
func cancel_dialog() -> void:
	if current_state:
		current_state.cancel_dialog()

# Find the speaker node by name
func get_speaker_node(target_name: String) -> Node2D:
	if player_node and player_node.name == target_name:
		return player_node

	var node = _find_node_recursive(main_node, target_name)
	if node and node is Node2D:
		return node

	return null

# Update current state every frame
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

# Pass unhandled input to current state
func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

# Recursively find a node by name starting from a root
func _find_node_recursive(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root

	for child in root.get_children():
		if child is Node:
			var found = _find_node_recursive(child, target_name)
			if found:
				return found

	return null
