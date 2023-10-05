extends Node2D

func _on_teleport_end():
	$ASPMusic.play()

func _ready():

	initialize_theme()
	set_random_tile_colour()
	$TileMapLevel1.can_climb.connect(_player_can_climb)
	$TileMapLevel1.visible = false
	$ASPTeleport.finished.connect(_on_teleport_end)
	$ASPTeleport.play()

func set_random_tile_colour():
	var random_color = Color(randf(), randf(), randf())
	$TileMapLevel1.modulate = random_color

func calculate_color(image : Image) -> Color:
	var map = $TileMapLevel1/TileMap
	var cell_size = map.tile_set.tile_size

	var r: float = 0.0
	var g: float = 0.0
	var b: float = 0.0

	for x in 4:
		var rnd : int = randi_range(0, len(map.get_used_cells(0)) - 1)
		var cell : Vector2i = map.get_used_cells(0)[rnd]
		var pix_x : int = (cell_size.x * cell.x) + (cell_size.x / 2)
		var pix_y : int = (cell_size.y * cell.y) + (cell_size.y / 8)
		var pix_color = image.get_pixel(pix_x, pix_y)
		r = r + pix_color.r
		g = g + pix_color.g
		b = b + pix_color.b

	var result : Color = Color(r / 4, g / 4, b / 4)
	return result

func initialize_theme():
	var id : int = randi() % Global._themes.size()
	var theme : MyTheme = Global._themes[id]

	print("using theme ", theme.name)

	var my_color = calculate_color(theme.texture.get_image())
	$Background.texture = theme.texture
	$HUD.set_theme(theme.category + " :: " + theme.name)
	$Door.set_color(my_color.inverted())
	$Player.set_color(my_color.inverted())

func toggle_tiles():
	$TileMapLevel1.visible = not $TileMapLevel1.visible
	$HUD.set_tiles($TileMapLevel1.visible)

func toggle_controls():
	$"Touch/Test/UI/Virtual joystick left".visible = not $"Touch/Test/UI/Virtual joystick left".visible

func _player_can_climb(state):
	$Player.can_climb = state

func _on_door_player_entered():
	get_tree().reload_current_scene.call_deferred()
	$"Touch/Test/UI/Virtual joystick left".reset()
	pass

func _input(event):
	if event.is_action_pressed("reset_level"):
		get_tree().reload_current_scene.call_deferred()
	elif event.is_action_pressed("toggle_tiles"):
		toggle_tiles()
	elif event.is_action_pressed("toggle_control"):
		toggle_controls()
