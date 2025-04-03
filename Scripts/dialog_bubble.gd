extends Control

@export var text_speed: float = 0.05

var text: String = ""
var text_index: int = 0
var is_typing: bool = false 
var speaker_node: Node2D = null

var dialog_lines: Array[String] = []
var line_index: int = 0
var full_line: String = "" 

@onready var text_label: RichTextLabel = $RichTextLabel
@onready var timer: Timer = $Timer

func _ready():
	text_label.visible = false
	timer.timeout.connect(_on_Timer_timeout)

# Start dialog with an array of lines
func show_dialog(lines: Array[String], speaker: Node2D):
	if lines.is_empty():
		return
	
	dialog_lines = lines
	line_index = 0
	speaker_node = speaker

	if speaker.is_in_group("Player"):
		global_position = speaker.global_position + Vector2(0, 50)
	else:
		global_position = speaker.global_position + Vector2(0, -50)

	text_label.visible = true
	_start_new_line()

# Start typing the current line
func _start_new_line():
	full_line = dialog_lines[line_index]
	text = ""
	text_index = 0
	is_typing = true
	text_label.text = ""
	_start_typing()

# Type each character
func _start_typing():
	if text_index < full_line.length():
		text += full_line[text_index]
		text_label.text = text
		text_index += 1
		timer.start(text_speed)
	else:
		is_typing = false

func _on_Timer_timeout():
	_start_typing()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept") and text_label.visible:
		if is_typing:
			# Finish the current line instantly
			text_label.text = full_line
			is_typing = false
		else:
			line_index += 1
			if line_index < dialog_lines.size():
				_start_new_line()
			else:
				# End of dialog
				text_label.visible = false
