extends Control

var is_dragging = false
var puzzle_won = false
var current_dragging_piece = null
@onready var gridSlots = get_child(0).get_children()

func _process(delta: float) -> void:
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
