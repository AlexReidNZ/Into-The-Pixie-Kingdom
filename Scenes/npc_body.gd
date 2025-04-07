extends CharacterBody2D

@onready var dialog_bubble = get_tree().root.get_node("Main/DialogBubble")
var player_in_range = false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		# Use the NPC's name as an identifier to fetch dialog lines from the DialogDatabase
		var npc_id = name  
		var lines = DialogDatabase.get_dialog(npc_id)
		dialog_bubble.show_dialog(lines, self)
