extends Control

var is_dragging = false
var puzzle_won = false
signal sig_win_puzzle
var current_dragging_piece = null
@onready var gridSlots = $GridBorderSprite/GridSlots.get_children()
@onready var puzzle_blocks = $GridBorderSprite/PuzzlePieces.get_children()
@onready var puzzle_indicator = $"../.."

func _ready() -> void:
	print("puzzle created")
	sig_win_puzzle.connect(puzzle_indicator._on_puzzle_won)

func _process(delta: float) -> void:
	if is_dragging and Input.is_action_just_pressed("rotate puzzle piece"):
		rotate_piece()
	if check_puzzle_won() and !puzzle_won:
		win_puzzle()

func win_puzzle():
	puzzle_won = true
	sig_win_puzzle.emit()

func check_puzzle_won():
	for slot in gridSlots:
		if !slot.slotTaken:
			return false
	return true

func rotate_piece():
	if current_dragging_piece:
		current_dragging_piece.rotate(deg_to_rad(90))

func reset_puzzle():
	for block in puzzle_blocks:
		block.global_position = block.initial_pos
	for slot in gridSlots:
		slot.slotTaken = false
