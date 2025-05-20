extends Area2D

# The name of the NPC this chat zone belongs to (set in Inspector or fallback to parent name)
@export var npc_name: String = ""

# Tracks whether the NPC's main dialog has been spoken
var has_spoken: bool = false

func _ready() -> void:
	monitoring = true

	# Use parent node's name if npc_name not set
	if npc_name == "":
		npc_name = get_parent().name

	# Connect signals for player entering and exiting this area
	connect("body_entered",  Callable(self, "_on_body_entered"))
	connect("body_exited",   Callable(self, "_on_body_exited"))

# Called when another body enters the area
func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return

	print("ENTER:", npc_name)

	# Fetch dialog lines for this NPC
	var lines = DialogDatabase.get_dialog(npc_name)
	if lines.size() == 0:
		# No dialog available
		return

	# First-time vs repeat logic
	if not has_spoken:
		# First interaction: offer full dialog
		DialogStateMachineAuto.offer_dialog(lines)
		has_spoken = true
	else:
		# Repeat interaction: offer a one-liner
		DialogStateMachineAuto.offer_dialog([
			{"speaker": npc_name, "line": "I have nothing more to say."}
		])

# Called when the body leaves the area
func _on_body_exited(body: Node) -> void:
	if body.name != "Player":
		return

	print("EXIT:", npc_name)
	DialogStateMachineAuto.cancel_dialog()
