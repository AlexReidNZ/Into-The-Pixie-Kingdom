extends TextureRect
var slotTaken = false

func _get_drag_data(at_position: Vector2) -> Variant:
	if (slotTaken):
		var data = {}
		data["origin_texture"] = texture
		
		var dragTexture = TextureRect.new()
		dragTexture.expand = true
		dragTexture.texture = texture
		dragTexture.size = dragTexture.texture.get_size()
		
		#use a control node to offset the drag preview so it is under the mouse instead of off to the side
		var control = Control.new()
		control.add_child(dragTexture)
		dragTexture.position = -0.5 * dragTexture.size
		set_drag_preview(control)
		
		return data
	return

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	slotTaken = true
	texture = data["origin_texture"]
	pass
