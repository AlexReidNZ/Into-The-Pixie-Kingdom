extends BaseState
class_name DialogState

# Offset for the dialog bubble relative to the speaker
const BUBBLE_OFFSET := Vector2(-200, -200)

# Preload the dialog bubble scene
const DIALOG_BUBBLE_SCENE := preload("res://Scenes/dialog_bubble.tscn")

# Dialog state variables
var dialog_lines: Array = []
var idx: int = 0
var full_text := ""
var char_i: int = 0
var typing := false
var accum := 0.0

# UI references
var bubble_instance: Control = null
var dialog_label: RichTextLabel = null
var timer: Timer = null

# Called when entering the Dialog state
func enter(data = null) -> void:
	if typeof(data) != TYPE_ARRAY or data.is_empty():
		state_machine.change_state("Idle")
		return

	dialog_lines = data.duplicate()
	idx = 0
	typing = false

	_disable_player()
	_create_bubble()
	_start_line()

# Instantiates and sets up the dialog bubble UI
func _create_bubble() -> void:
	bubble_instance = DIALOG_BUBBLE_SCENE.instantiate()
	state_machine.get_tree().current_scene.add_child(bubble_instance)

	dialog_label = bubble_instance.get_node("NinePatchRect/RichTextLabel") as RichTextLabel
	timer = bubble_instance.get_node("Timer") as Timer

	timer.wait_time = state_machine.text_speed
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_on_Timer_timeout)

	dialog_label.text = ""
	bubble_instance.visible = true

# Starts displaying a line of dialog
func _start_line() -> void:
	var d = dialog_lines[idx]
	full_text = str(d.get("line", ""))
	char_i = 0
	typing = true
	accum = 0.0
	dialog_label.text = ""

	# Position bubble above speaker
	var speaker = str(d.get("speaker", ""))
	var speaker_node = state_machine.get_speaker_node(speaker)
	if speaker_node:
		bubble_instance.global_position = speaker_node.global_position + BUBBLE_OFFSET

	timer.start()

# Adds the next character to the dialog text
func _on_Timer_timeout() -> void:
	if char_i < full_text.length():
		dialog_label.text += full_text[char_i]
		char_i += 1
	else:
		typing = false
		timer.stop()

# Called every frame (if update is used)
func update(delta: float) -> void:
	if typing:
		accum += delta
		if accum >= state_machine.text_speed:
			accum -= state_machine.text_speed
			_on_Timer_timeout()

# Handle input for skipping or progressing dialog
func handle_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return

	if typing:
		# Skip typing animation
		dialog_label.text = full_text
		char_i = full_text.length()
		typing = false
		timer.stop()
	else:
		# Go to next line or end dialog
		idx += 1
		if idx < dialog_lines.size():
			_start_line()
		else:
			state_machine.change_state("Idle")

# Called when exiting the dialog state
func exit() -> void:
	if bubble_instance:
		bubble_instance.queue_free()
		bubble_instance = null

	dialog_lines.clear()
	_enable_player()

# Disables player movement/input
func _disable_player() -> void:
	if state_machine.player_node:
		state_machine.player_node.set_physics_process(false)
		state_machine.player_node.set_process_input(false)

# Enables player movement/input
func _enable_player() -> void:
	if state_machine.player_node:
		state_machine.player_node.set_physics_process(true)
		state_machine.player_node.set_process_input(true)
