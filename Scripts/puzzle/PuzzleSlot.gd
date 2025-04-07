extends TextureRect

func _get_drag_data(at_position: Vector2) -> Variant:
	var data = {}
	
	var dragTexture = TextureRect.new()
	dragTexture.expand = true
	dragTexture.texture = texture
	dragTexture.size = Vector2(20,20)
	
	#use a control node to offset the drag preview so it is under the mouse instead of off to the side
	var control = Control.new()
	control.add_child(dragTexture)
	dragTexture.position = -0.5 * dragTexture.size
	set_drag_preview(control)
	
	return data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	texture = data["origin_texture"]
	pass
