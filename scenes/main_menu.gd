extends Node2D

@onready var _pb = $CenterContainer/VBoxContainer/PanelProgress/VBoxContainer/Panel/ProgressBar
@onready var _msg = $CenterContainer/VBoxContainer/PanelProgress/VBoxContainer/Panel/Loading
@onready var _start = $CenterContainer/VBoxContainer/PanelButtons/VBoxContainer2/StartButton
@onready var _quit = $CenterContainer/VBoxContainer/PanelButtons/VBoxContainer2/QuitButton
var _loaded : bool
var _scene : Resource
var _root : String = "res://gen"

# Called when the node enters the scene tree for the first time.
func _ready():

	_pb.visible = false
	_loaded = false

	if OS.has_feature("web"):
		print("running in a browser")
	if !OS.has_feature("pc"):
		_quit.hide()
	else:
		print("running on pc")

	$AudioStreamPlayer.play()
	if len(Global._themes) == 0:
		randomize()
		var root = self._root
		var args = OS.get_cmdline_user_args()
		for arg in args:
			if arg.find("=") > -1:
				var key_value = arg.split("=")
				if key_value[0] == "--theme":
					root += "/" + key_value[1]
		load_themes(root)
	else:
		_loaded = true
		_msg.text = "Loading complete"

	if not _scene:
		_scene = preload("res://scenes/demo_level.tscn")

func _on_start_button_pressed():
	if not _loaded or not _scene:
		return
	get_tree().change_scene_to_packed(_scene)

func _on_fullscreen_button_pressed():
	var mode  = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_quit_button_pressed():
	print("Quitting!")
	get_tree().quit()

func recurse_image_paths(root, image_paths) -> void: 
	print("scanning directory : ", root)
	var dir = DirAccess.open(root)
	if dir:
		print("directory is valid")
		dir.list_dir_begin()
		var file_name = dir.get_next()
		print("initial file_name : ", file_name)
		while file_name != "":
			if dir.current_is_dir():
				var new_root = root + "/" + file_name
				print("Found directory: " + new_root)
				recurse_image_paths(new_root, image_paths)
			else:
				if OS.has_feature("web"):
					if (file_name.ends_with(".import")):
						var fq_file_name = root + "/" + file_name.replace(".import", "")
						print("Found file: " + fq_file_name)
						image_paths.append(fq_file_name)
				else:
					if (file_name.ends_with(".import")):
						pass
					else:
						var fq_file_name = root + "/" + file_name
						print("Found file: " + fq_file_name)
						image_paths.append(fq_file_name)
			file_name = dir.get_next()
			#print("loop file_name : ", file_name)
	else:
		print("An error occurred when trying to access the path ", root)

func load_themes(path):

	print("Loading themes from " + path)

	_start.disabled = true
	var image_paths = []
	recurse_image_paths(path, image_paths)
	var num_images = len(image_paths)

	_pb.max_value = num_images
	_pb.visible = true

	var counter = 0
	for image_path in image_paths:
		if not image_path.ends_with(".png"):
			continue
		_pb.value = counter
		_msg.text = "Loading " + image_path
		await get_tree().create_timer(0.05).timeout
		counter = counter + 1
		Global._themes.append( MyTheme.load_theme(image_path) )

	if counter == 0 and path != self._root:
		load_themes(self._root)

	_pb.visible = false
	_msg.text = "Loading complete"
	print("Loading complete")
	_start.disabled = false
	_loaded = true
