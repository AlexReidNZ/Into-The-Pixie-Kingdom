extends Control

var is_dragging = false
var current_dragging_piece = null
@onready var gridSlots = get_child(0).get_children()

func _process(delta: float) -> void:
	if puzzle_won():
		win_puzzle()

func win_puzzle():
	print("puzzle complete")
	pass

func puzzle_won():
	for slot in gridSlots:
		if !slot.slotTaken:
			return false
	return true
