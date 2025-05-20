extends BaseState
class_name DialogState

const BUBBLE_OFFSET        := Vector2(-50, 0)
const MAX_BUBBLE_WIDTH     := 300
const MAX_BUBBLE_HEIGHT    := 999
const DIALOG_BUBBLE_SCENE  := preload("res://Scenes/dialog_bubble.tscn")

var dialog_lines: Array = []
var idx: int = 0
var full_text: String = ""
var char_i: int = 0
var typing: bool = false
var accum: float = 0.0
var dialogue_audio: AudioStreamPlayer

var bubble_instance: Control = null
var dialog_label: RichTextLabel = null
var timer: Timer = null
var tail_sprite: Sprite2D = null
var _tail_initial_pos: Vector2

func enter(data = null) -> void:
	if typeof(data) != TYPE_ARRAY or data.is_empty():
		return state_machine.change_state("Idle")
	dialog_lines = data.duplicate()
	idx = 0
	_disable_player()
	_create_bubble()
	call_deferred("_start_line") # ensures correct scene tree timing

func _create_bubble() -> void:
	bubble_instance = DIALOG_BUBBLE_SCENE.instantiate()
	state_machine.get_tree().current_scene.add_child(bubble_instance)
	dialog_label = bubble_instance.get_node("NinePatchRect/RichTextLabel")
	timer = bubble_instance.get_node("Timer")
	tail_sprite = bubble_instance.get_node("Sprite2D")
	_tail_initial_pos = tail_sprite.position
	dialog_label.text = ""
	dialog_label.custom_minimum_size = Vector2.ZERO
	dialog_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	timer.wait_time = state_machine.text_speed
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_on_Timer_timeout)
	bubble_instance.visible = true

func _start_line() -> void:
	_start_line_async() # call as a detached coroutine

func _start_line_async() -> void:
	full_text = str(dialog_lines[idx].get("line", ""))
	await _pre_size_bubble(full_text)
	dialog_label.text = ""
	char_i = 0
	typing = true
	var speaker = state_machine.get_speaker_node(str(dialog_lines[idx].get("speaker", "")))
	if speaker:
		# set position of entire bubble based on tail pos marker on speaker
		var tail_position := speaker.get_node("DialogueTailPos") as Marker2D
		var distance := tail_position.global_position - tail_sprite.global_position
		bubble_instance.global_position += distance
		dialogue_audio = speaker.get_node("Audio/Dialogue") as AudioStreamPlayer
		dialogue_audio.play()
	timer.start()

func _pre_size_bubble(text: String) -> void:
	const pad = Vector2(20, 20)
	dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	dialog_label.custom_minimum_size = Vector2.ZERO
	dialog_label.text = text
	var w = min(dialog_label.get_content_width(), MAX_BUBBLE_WIDTH)
	var h = min(dialog_label.get_content_height(), MAX_BUBBLE_HEIGHT)
	dialog_label.custom_minimum_size = Vector2(w, h)
	var bg = bubble_instance.get_node("NinePatchRect") as NinePatchRect
	bg.custom_minimum_size = Vector2(w, h) + pad
	tail_sprite.position = Vector2((w + pad.x) * 0.5, h + pad.y)

func _on_Timer_timeout() -> void:
	if char_i < full_text.length():
		dialog_label.text += full_text[char_i]
		char_i += 1
	else:
		typing = false
		timer.stop()
		dialogue_audio.stop()

func update(delta: float) -> void:
	if typing:
		accum += delta
		if accum >= state_machine.text_speed:
			accum -= state_machine.text_speed
			_on_Timer_timeout()

func handle_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return
	if typing:
		dialog_label.text = full_text
		char_i = full_text.length()
		typing = false
		timer.stop()
		dialogue_audio.stop()
	else:
		idx += 1
		if idx < dialog_lines.size():
			call_deferred("_start_line")
		else:
			state_machine.change_state("Idle")

func exit() -> void:
	if bubble_instance:
		bubble_instance.queue_free()
		bubble_instance = null
	dialog_lines.clear()
	_enable_player()

func _disable_player() -> void:
	if state_machine.player_node:
		state_machine.player_node.move_state = Player.MoveState.PAUSED

func _enable_player() -> void:
	if state_machine.player_node:
		state_machine.player_node.move_state = Player.MoveState.IDLE
