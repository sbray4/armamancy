extends Control

@export var player : CharacterBody3D
@export var weapon_manager : WeaponManager

func _process(delta: float) -> void:
	# Update health box
	%HealthLabel.text = str(player.hp)
	
	# Update ammo box
	if not weapon_manager.current_weapon or weapon_manager.current_weapon == weapon_manager.equipped_weapons[0]:
		%AmmoBox.visible = false
	else:
		%AmmoBox.visible = true
		#if weapon_manager.current_weapon.current_ammo == INF:
		#	%AmmoLabel.text = "∞"
		#else:
		#	%AmmoLabel.text = str(weapon_manager.current_weapon.current_ammo)
		%AmmoLabel.text = str(weapon_manager.current_weapon.current_ammo)
