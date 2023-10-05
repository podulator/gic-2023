extends Area2D

signal player_entered()

func set_color(color : Color):
	self.modulate = color

func _on_body_entered(body):
	if body.name == "Player":
		player_entered.emit()
