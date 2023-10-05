extends Node2D

signal rendered
signal can_climb

func _ready():
	print("TileMapLevel1 loaded")
	$Renderer.rendered.connect(_on_render_complete)
	pass

func toggleBackground(state : bool):
	$ColorRect.visible = state

func render():
	toggleBackground(true)
	$Renderer.render($TileMap)

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
