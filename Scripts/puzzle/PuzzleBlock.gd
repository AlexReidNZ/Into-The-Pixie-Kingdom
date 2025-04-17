extends Node2D

@onready var puzzleManager = $".."
@onready var collider = $Area2D
@onready var gridColliders = get_child(0).get_children()
var draggable = false
var is_droppable = false
var body_Ref
@onready var start_pos = global_position

func  _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click"): #Set slot taken to false for all colliding shapes
			StartDrag()
		if Input.is_action_pressed("click"):
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("click"):
			DropPiece()

func _on_area_2d_mouse_entered() -> void:
	if not puzzleManager.is_dragging:
		puzzleManager.is_dragging = true
		draggable = true
		scale = Vector2(1.05,1.05)

func _on_area_2d_mouse_exited() -> void:
	if not puzzleManager.is_dragging:
		draggable = false
		scale = Vector2(1,1)

func DropPiece():
	print("drag stopped")
	if is_valid_position():
		print("valid")
		for area in gridColliders:
			area.get_overlapping_areas()[0].slotTaken = true
		
		global_position -= gridColliders[0].global_position - gridColliders[0].get_overlapping_areas()[0].global_position
	else:
		set_global_position(start_pos)
	puzzleManager.is_dragging = false

func StartDrag():
	start_pos = global_position
	for area in gridColliders:
		if area.has_overlapping_areas(): #if piece is in the grid
			area.get_overlapping_areas()[0].slotTaken = false

func is_valid_position():
	for area in gridColliders:
		if !area.has_overlapping_areas(): #these colliders only detect grid squares, so this checks each spot is over a grid square
			return false
		elif area.get_overlapping_areas()[0].slotTaken: #if the slot it overlaps is already taken
			return false
	return true
