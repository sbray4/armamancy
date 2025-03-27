extends RigidBody3D

@export var hp = 400

func _process(delta: float) -> void:
	$"Label3D".text = "HP: " + str(hp)

func take_damage(amount: float):
	hp -= amount
	if hp <= 0:
		queue_free()
