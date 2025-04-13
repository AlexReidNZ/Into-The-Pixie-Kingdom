extends Node2D

@onready var puzzleManager = $".."
var draggable = false
var is_droppable = false
var body_Ref

func  _process(delta: float) -> void:
	if draggable:
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
	puzzleManager.is_dragging = false
