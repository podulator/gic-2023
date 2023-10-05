extends Node2D

signal rendered

func render(map : TileMap):

	var parent = self.get_parent()
	print("Rendering : ", parent.name)

	await RenderingServer.frame_post_draw
	await get_tree().create_timer(1).timeout

	var cell_size = map.tile_set.tile_size
	var map_tile_size = map.get_used_rect()
	var vp = get_viewport().get_visible_rect().size
	var map_pix_width = map_tile_size.size.x * cell_size.x
	var map_pix_height = map_tile_size.size.y * cell_size.y
	var map_pix_offset_x = map_tile_size.position.x * cell_size.x
	var map_pix_offset_y = map_tile_size.position.y * cell_size.y

	print("cell size : ", cell_size)
	print("map tile size : ", map_tile_size)
	print("viewport size : ", vp)
	print("map pixel dimensions : (", map_pix_width, ", ", map_pix_height, ")")
	print("map pixel offset : (", map_pix_offset_x , ", ", map_pix_offset_y, ")")
	print("Screen size : ", DisplayServer.screen_get_size())

	# find the biggest extent
	var vp_max_x = get_viewport().get_visible_rect().size.x
	var vp_max_y = get_viewport().get_visible_rect().size.y
	var map_max_x = map_pix_offset_x + map_pix_width
	var map_max_y = map_pix_offset_y + map_pix_height
	
	var max_x = max(vp_max_x, map_max_x)
	var max_y = max(vp_max_y, map_max_y)

	print("final map size : (", max_x, ", " , max_y, ")")
	var format = get_viewport().get_texture().get_image().get_format()
	var img = Image.create(max_x, max_y, false, format)

	var current_y = 0
	var current_x = 0
	var sourceRect = get_viewport().get_visible_rect()

	var moreY = true
	var yStep = int(vp_max_y  / 5)
	var xStep = int(vp_max_x / 5)

	while moreY:
		map.position.y = current_y
		current_x = 0
		#print("map y = ", map.position.y)
		while current_x < max_x:
			map.position.x = -current_x
			#print("map x = ", map.position.x)
			map.can_process()
			await RenderingServer.frame_post_draw
			await get_tree().create_timer(0.05).timeout
			var chunk = get_viewport().get_texture().get_image()
			var destPos = Vector2i(current_x, abs(current_y))
			img.blit_rect(chunk, sourceRect, destPos)
			current_x = current_x + xStep

		current_y = current_y - yStep
		if current_y < -max_y - yStep:
			moreY = false

	var template = "template-" +  parent.name + ".png"
	var dir = DirAccess.open(".")
	if dir:
		if not dir.dir_exists("templates"):
			dir.make_dir("templates")

	img.save_png("./templates/" + template)
	print("render saved to : ", template)
	await RenderingServer.frame_post_draw
	rendered.emit()
