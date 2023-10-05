extends Node

func _ready():

	var render = false
	var args = OS.get_cmdline_user_args()
	for arg in args:
		if arg == "--render":
			render = true

	if render:
		var scene = load("res://scenes/TileMapLevel1.tscn")
		var instance = scene.instantiate()
		instance.rendered.connect(_on_render_completed)
		get_tree().root.add_child.call_deferred(instance)
		await RenderingServer.frame_post_draw
		await get_tree().create_timer(1).timeout
		instance.render()
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_render_completed():
	print("Render completed, unloading")
	get_tree().quit()
