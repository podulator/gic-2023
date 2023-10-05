extends RefCounted

class_name MyTheme

var _path : String
var path : String : 
	get:
		return _path

var _name : String
var name : String :
	get:
		return _name
	set(value):
		_name = value
		
var _category : String
var category : String :
	get:
		return _category
	set(value):
		_category = value

var _texture : Texture
var texture : Texture : 
	get:
		return _texture
	set(value):
		_texture = value

var _dominant_color : Color
var dominant_color : Color :
	get: 
		return _dominant_color
	set(value):
		_dominant_color = value

func _init(root):
	self._path = root

static func load_theme(root : String) -> MyTheme :
	print("loading theme from : ", root)
	var inst : MyTheme = MyTheme.new(root)
	var dir = root.get_base_dir()
	var cat = dir.get_slice("/", dir.get_slice_count("/") - 1)
	inst.texture = load(root)
	inst.category = cat
	inst.name = root.get_file().get_basename()
	return inst
