extends CharacterBody2D

@onready var dialog_bubble = get_node("/root/Main/DialogBubble")
var dialog_started: bool = false

func _ready() -> void:
	# Connect area signals 
	$ChatDetection.body_entered.connect(_on_body_entered)
	$ChatDetection.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") and !dialog_started:
		print("BODY THAT ENTERED:", body.name)
		dialog_started = true  # prevent re-triggering immediately
		# Fetch this NPC's dialog lines from the database
		var lines: Array = DialogDatabase.get_dialog(self.name)
		if lines.size() > 0:
			dialog_bubble.show_dialog(lines)
		else:
			# No dialog found for this NPC
			print("No dialog for NPC:", self.name)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		dialog_started = false  # allow dialog to trigger again next time player enters
