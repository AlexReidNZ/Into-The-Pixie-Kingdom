extends Control

@export var text_speed: float = 0.05

var dialog_lines: Array = []
var line_index: int = 0
var is_typing: bool = false
var dialog_active: bool = false

var full_text: String = ""
var char_index: int = 0
var current_speaker_node: Node2D = null

@onready var text_label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer

func _ready() -> void:
	visible = false
	timer.wait_time = text_speed
	timer.timeout.connect(_on_Timer_timeout)

func show_dialog(lines: Array) -> void:
	if lines.is_empty():
		return

	dialog_lines = lines
	line_index = 0
	dialog_active = true

	var player_node = get_speaker_node("Player")
	if player_node:
		player_node.set_physics_process(false)
		player_node.set_process_input(false)

	_start_new_line()

func _start_new_line() -> void:
	var line_data = dialog_lines[line_index]
	var speaker_name = line_data.get("speaker", "")
	full_text = line_data.get("line", "")
	char_index = 0
	is_typing = true
	text_label.text = ""

	current_speaker_node = get_speaker_node(speaker_name)
	if current_speaker_node:
		global_position = current_speaker_node.global_position + Vector2(0, -50)
		print("=== DIALOG DEBUG ===")
		print("Line index:", line_index)
		print("Speaker:", speaker_name)
		print("Speaker node:", current_speaker_node.name if current_speaker_node else "null")
		print("Global Position Set To:", global_position)
	else:
		push_warning("Could not find speaker: " + speaker_name)

	visible = true
	text_label.visible = true
	timer.start()

func _on_Timer_timeout() -> void:
	if char_index < full_text.length():
		text_label.text += full_text[char_index]
		char_index += 1
	else:
		is_typing = false
		timer.stop()

func _unhandled_input(event: InputEvent) -> void:
	if not dialog_active:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
		if is_typing:
			timer.stop()
			is_typing = false
			text_label.text = full_text
		else:
			line_index += 1
			if line_index < dialog_lines.size():
				_start_new_line()
			else:
				_end_dialog()

func _end_dialog() -> void:
	dialog_active = false
	is_typing = false
	text_label.visible = false
	visible = false

	var player_node = get_speaker_node("Player")
	if player_node:
		player_node.set_physics_process(true)
		player_node.set_process_input(true)

func get_speaker_node(speaker_name: String) -> Node2D:
	var root = get_tree().get_root().get_node("Main")
	if root == null:
		return null

	for child in root.get_children():
		if child.name == speaker_name and child is Node2D:
			return child

	return null
