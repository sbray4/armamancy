extends Label

func _process(delta: float) -> void:
	text = "Speed: " + str(snapped(($"../..".player.velocity * Vector3(1, 0, 1)).length(), 0.1)) + " m/s"
