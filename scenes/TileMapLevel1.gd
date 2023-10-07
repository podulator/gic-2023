extends Node2D

signal rendered
signal can_climb

func get_bounds() -> Rect2i :
	var cell_size = $TileMap.tile_set.tile_size
	var map_tile_size = $TileMap.get_used_rect()
	var vp = get_viewport().get_visible_rect().size
	var map_pix_width = map_tile_size.size.x * cell_size.x
	var map_pix_height = map_tile_size.size.y * cell_size.y
	return Rect2i(map_tile_size.position.x, map_tile_size.position.y, map_pix_width, map_pix_height)

func toggleBackground(state : bool):
	$ColorRect.visible = state

func render():
	toggleBackground(true)
	$Renderer.render($TileMap)

func _ready():
	print("TileMapLevel1 loaded")
	$Renderer.rendered.connect(_on_render_complete)
	pass

func _on_render_complete():
	rendered.emit()

func _on_ladder_area_body_entered(body):
	if body.name == "Player":
		#print("Player over ladder")
		can_climb.emit(true)

func _on_ladder_area_body_exited(body):
	if body.name == "Player":
		#print("Player left ladder")
		can_climb.emit(false)
