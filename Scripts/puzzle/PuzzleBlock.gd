extends TextureRect

func _get_drag_data(at_position: Vector2) -> Variant:
	var data = {}
	
	var dragTexture = TextureRect.new()
	dragTexture.expand = true
	dragTexture.texture = texture
	dragTexture.size = Vector2(20,20)
	
	set_drag_preview(dragTexture)
	
	return data
