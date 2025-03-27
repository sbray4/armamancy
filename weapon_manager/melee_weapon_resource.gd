class_name MeleeWeaponResource
extends WeaponResource

@export var max_hit_dist = 3

@export var miss_sound : AudioStream

func fire_shot():
	weapon_manager.play_anim(view_shoot_anim)
	weapon_manager.queue_anim(view_idle_anim)
	
	var raycast = weapon_manager.bullet_raycast
	raycast.target_position = Vector3(0,0,-max_hit_dist)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		weapon_manager.play_sound(shoot_sound)
		var obj = raycast.get_collider()
		var nrml = raycast.get_collision_normal()
		var pt = raycast.get_collision_point()
		if obj is RigidBody3D:
			obj.apply_impulse(-nrml * 5.0 / obj.mass, pt - obj.global_position)
		if obj.has_method("take_damage"):
			obj.take_damage(damage)
	else:
		weapon_manager.play_sound(miss_sound)
	
	last_fire_time = Time.get_ticks_msec()
