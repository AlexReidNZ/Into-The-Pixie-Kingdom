extends Control

var is_dragging = false
var puzzle_won = false
var current_dragging_piece = null
@onready var gridSlots = get_child(0).get_children()

func _process(delta: float) -> void:
	if is_dragging and Input.is_action_just_pressed("rotate puzzle piece"):
		rotate_piece()
	if check_puzzle_won() and !puzzle_won:
		win_puzzle()

func win_puzzle():
	puzzle_won = true
	print("puzzle complete")

func check_puzzle_won():
	for slot in gridSlots:
		if !slot.slotTaken:
			return false
	return true

func rotate_piece():
	if current_dragging_piece:
		current_dragging_piece.rotate(deg_to_rad(90))
