extends Node2D

@onready var puzzleManager = $".."
@onready var collider = $Area2D
@onready var gridColliders = get_child(0).get_children()
var draggable = false
var is_droppable = false
var current_overlaps = []
@onready var start_pos = global_position

func  _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click"): #Set slot taken to false for all colliding shapes
			start_drag()
		if Input.is_action_pressed("click") and puzzleManager.current_dragging_piece == self:
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("click"):
			drop_piece()

func _on_area_2d_mouse_entered() -> void:
	if not puzzleManager.is_dragging:
		draggable = true
		scale = Vector2(1.05,1.05)

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
			if area.has_overlapping_areas(): #if pos not valid and overlaps grid, return to start pos
				global_position = start_pos
				break
	await get_tree().create_timer(0.05).timeout #This is a hacky fix, but its the only way I can figure out to get it working
	for slot in current_overlaps:
		slot.slotTaken = false
	for area in gridColliders:
		if area.has_overlapping_areas():
			area.get_overlapping_areas()[0].slotTaken = true

func start_drag():
	current_overlaps.clear()
	start_pos = global_position
	puzzleManager.is_dragging = true
	puzzleManager.current_dragging_piece = self
	for area in gridColliders:
		if area.has_overlapping_areas(): #if piece is in the grid
			current_overlaps.append(area.get_overlapping_areas()[0])

func is_valid_position():
	for area in gridColliders:
		if !area.has_overlapping_areas(): #these colliders only detect grid squares, so this checks each spot is over a grid square
			return false
		elif area.get_overlapping_areas()[0].slotTaken and !current_overlaps.has(area.get_overlapping_areas()[0]): #if the slot it overlaps is already taken
			return false
	return true

func cancel_drag():
	draggable = false
	scale = Vector2(1,1)
