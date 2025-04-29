extends Control

var is_dragging = false
var current_dragging_piece = null

@onready var gridSlots = get_child(0).get_children()

func _process(delta: float) -> void:
	if PuzzleWon():
		WinPuzzle()

func WinPuzzle():
	print("puzzle complete")
	pass

func PuzzleWon():
	for slot in gridSlots:
		if !slot.slotTaken:
			return false
	return true
