extends CanvasLayer

func set_tiles(state : bool):
	$TilesLabel.text = "Tiles : On" if state else "Tiles : Off"

func set_theme(title):
	$ThemeLabel.text = title
