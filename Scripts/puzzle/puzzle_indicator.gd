extends Area2D

@export var puzzle_scene : PackedScene
@export var puzzle_group : String
@export var fixed_sprite : Texture2D
@export var sprite_object : Sprite2D
@export var sprite_collision : CollisionShape2D
@onready var canvas = $CanvasLayer
@onready var player: Player = %Player
var clickable = false
var puzzle_active = false
var puzzle_instance
var puzzle_slots

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	puzzle_instance = puzzle_scene.instantiate()
	canvas.add_child(puzzle_instance)
	puzzle_instance.hide()
	puzzle_slots = get_tree().get_first_node_in_group(puzzle_group).get_children()
	for i in puzzle_slots:
		i.get_child(0).disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clickable and !puzzle_active and Input.is_action_just_pressed("click"):
		toggle_puzzle()

func _on_mouse_entered() -> void:
	clickable = true

func _on_mouse_exited() -> void:
	clickable = false

func toggle_puzzle():
	puzzle_active = !puzzle_active
	
	if puzzle_instance: #make sure puzzle instantiated correctly
		if puzzle_active:
			puzzle_instance.show()
			for i in puzzle_slots:
				i.get_child(0).disabled = false
			player.move_state = Player.MoveState.PAUSED
		else:
			puzzle_instance.hide()
			for i in puzzle_slots:
				i.get_child(0).disabled = true
			player.move_state = Player.MoveState.IDLE
			
func _on_puzzle_won():
	print("puzzle has been won")
	toggle_puzzle()
	sprite_object.texture = fixed_sprite
	if sprite_collision:
		sprite_collision.disabled = true
	self.hide()
