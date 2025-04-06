extends Node2D

@export var GridSquare : PackedScene #Object containing a square of the grid with collider, to instantiate on start
@export var PuzzHeight : int #Set size of puzzle in inspector for variable puzzle sizes
@export var PuzzWidth : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in PuzzWidth:
		for y in PuzzHeight:
			GridSquare.instantiate()
			#TODO: Set position of each square
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
