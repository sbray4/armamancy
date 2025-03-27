class_name WeaponResource
extends Resource

@export var name : String

#@export_range(1,9) var slot : int = 1

@export var view_model : PackedScene
#@export var world_model : PackedScene

@export var view_model_pos : Vector3
@export var view_model_rot : Vector3
@export var view_model_scale := Vector3(1,1,1)
#@export var world_model_pos : Vector3
#@export var world_model_rot : Vector3
#@export var world_model_scale := Vector3(1,1,1)


## Animations
@export var view_idle_anim : String
@export var view_equip_anim : String
@export var view_shoot_anim : String

## Sounds
@export var shoot_sound : AudioStream
@export var unholster_sound : AudioStream

## Weapon Logic

@export var damage = 10

@export var current_ammo : int = 9999
@export var max_ammo : int = 9999

@export var auto_fire : bool = true
@export var max_fire_rate_ms : float = 50

const RAYCAST_DIST : float = 9999 # Too far seems to break it

var weapon_manager : WeaponManager

var trigger_down := false :
	set(v):
		if trigger_down != v:
			trigger_down = v
			if trigger_down:
				on_trigger_down()
			else:
				on_trigger_up()

var is_equipped := false :
	set(v):
		if is_equipped != v:
			is_equipped = v
			if is_equipped:
				on_equip()
			else:
				on_unequip()

var last_fire_time = -999999

func on_process(delta):
	if trigger_down and auto_fire and Time.get_ticks_msec() - last_fire_time >= max_fire_rate_ms:
		if current_ammo > 0:
			fire_shot()

func on_trigger_down():
	if Time.get_ticks_msec() - last_fire_time >= max_fire_rate_ms and current_ammo > 0:
		fire_shot()

func on_trigger_up():
	pass

func on_equip():
	weapon_manager.play_sound(unholster_sound) # is this in the right spot?
	weapon_manager.play_anim(view_equip_anim)
	weapon_manager.queue_anim(view_idle_anim)

func on_unequip():
	pass

func fire_shot():
	weapon_manager.play_anim(view_shoot_anim)
	weapon_manager.play_sound(shoot_sound)
	weapon_manager.queue_anim(view_idle_anim)
	
	var raycast = weapon_manager.bullet_raycast
	raycast.target_position = Vector3(0,0,-RAYCAST_DIST)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		var nrml = raycast.get_collision_normal()
		var pt = raycast.get_collision_point()
		if obj is RigidBody3D:
			obj.apply_impulse(-nrml * 5.0 / obj.mass, pt - obj.global_position)
		if obj.has_method("take_damage"):
			obj.take_damage(damage)
	
	last_fire_time = Time.get_ticks_msec()
	current_ammo -= 1
