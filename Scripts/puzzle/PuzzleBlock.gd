extends Node2D

@onready var puzzleManager = $".."
@onready var collider = $Area2D
var draggable = false
var is_droppable = false
var body_Ref

func  _process(delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click"): #Set slot taken to false for all colliding shapes
			for slot in collider.get_overlapping_areas():
				slot.slotTaken = false
				print(str(slot.name," ",slot.slotTaken))
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
	for slot in collider.get_overlapping_areas():
		slot.slotTaken = true
		print(str(slot.name," ",slot.slotTaken))
	puzzleManager.is_dragging = false
