extends Node2D

@onready var puzzleManager = $"../../.."
@onready var collider = $Area2D
@onready var sprite = $Sprite2D

@onready var gridColliders = get_child(0).get_children()
@onready var initial_pos = global_position

var draggable = false
var is_droppable = false
var current_overlaps = []
@onready var start_pos = global_position
var initial_scale
@onready var puzzle_audio: PuzzleAudio = %PuzzleAudio

func _ready() -> void:
	initial_scale = transform.get_scale()

func _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click"):
			start_drag()
		if Input.is_action_pressed("click") and puzzleManager.current_dragging_piece == self:
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("click"):
			drop_piece()

func _on_area_2d_mouse_entered() -> void:
	if not puzzleManager.is_dragging:
		draggable = true
		scale = Vector2(1.05,1.05) * initial_scale

func _on_area_2d_mouse_exited() -> void:
	if not puzzleManager.is_dragging:
		cancel_drag()

func drop_piece():
	if puzzleManager.current_dragging_piece == self:
		puzzleManager.is_dragging = false
		cancel_drag()
		puzzleManager.current_dragging_piece = null
	if is_valid_position():
		var total_offset = Vector2.ZERO
		var count = 0
		for area in gridColliders:
			var overlaps = area.get_overlapping_areas()
			if overlaps.size() > 0:
				total_offset += area.global_position - overlaps[0].global_position
				count += 1
		if count > 0:
			global_position -= total_offset / count
	else:
		for area in gridColliders:
			if area.has_overlapping_areas():
				global_position = start_pos
				break
	await get_tree().create_timer(0.05).timeout
	# Safely clear old slots
	for slot in current_overlaps:
		if slot and slot.has_method("slotTaken"):
			slot.slotTaken = false
	# Set new slots taken
	for area in gridColliders:
		if area.has_overlapping_areas():
			var slot = area.get_overlapping_areas()[0]
			if slot and slot.has_method("slotTaken"):
				slot.slotTaken = true
	puzzle_audio.play_place_block()

func start_drag():
	puzzle_audio.play_pickup_block()
	# Free up any slots you are currently occupying (with safety)
	for area in gridColliders:
		if area.has_overlapping_areas():
			var slot = area.get_overlapping_areas()[0]
			if slot and slot.has_method("slotTaken"):
				slot.slotTaken = false
	current_overlaps.clear()
	start_pos = global_position
	puzzleManager.is_dragging = true
	puzzleManager.current_dragging_piece = self
	for area in gridColliders:
		if area.has_overlapping_areas():
			var slot = area.get_overlapping_areas()[0]
			if slot and not current_overlaps.has(slot):
				current_overlaps.append(slot)

func is_valid_position():
	for area in gridColliders:
		if !area.has_overlapping_areas():
			return false
		var slot = area.get_overlapping_areas()[0]
		if slot and slot.slotTaken and not current_overlaps.has(slot):
			return false
	return true

func cancel_drag():
	draggable = false
	scale = Vector2(1,1) * initial_scale
