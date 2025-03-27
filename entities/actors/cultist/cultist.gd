@tool
class_name Cultist
extends Actor

@onready var nav: NavigationAgent3D = $NavigationAgent3D

@export var speed : float
var attacking = false
var wish_dir : Vector3

func _func_godot_apply_properties(props: Dictionary) -> void:
	speed = props["speed"] as float

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	#nav.target_desired_distance = 5
	
	if GAME.player:
		$VisionRayCast3D.look_at(GAME.player.position)
		$VisionRayCast3D.force_raycast_update()
		
		if $VisionRayCast3D.is_colliding():
			var collider = $VisionRayCast3D.get_collider()
			
			if collider == GAME.player:
				nav.target_position = GAME.player.global_position
				
				if $VisionRayCast3D.global_position.distance_to($VisionRayCast3D.get_collision_point()) < 2:
					# Attack
					#look_at(player.global_position)
					attacking = true
				else:
					attacking = false
	
	#if nav.is_target_reached():
	#	print(randf())
	#	return
	
	#if nav.is_navigation_finished():
	#	print("hi")
	#	return
	
	var stop_moving = false
	var next_location
	if nav.is_navigation_finished() or (!nav.is_target_reachable() and nav.distance_to_target() < 0.1) or (nav.is_target_reachable() and stop_moving):
		stop_moving = true
		next_location = global_position # need to optimize this later
	else:
		stop_moving = false
		next_location = nav.get_next_path_position()
	
	#var next_location
	#if !nav.is_navigation_finished() or !stop_moving:
	#	next_location = nav.get_next_path_position()
	#else:
	#	next_location = global_position # need to optimize this later
	
	#var next_location = nav.get_next_path_position()
	#print(global_position.distance_to(next_location))
	if next_location != global_position:
		#look_at(next_location)
		# Y component is remove from the wish_dir
		wish_dir = global_position.direction_to(next_location) * Vector3(1, 0, 1)
		#wish_dir.y = 0
		var target: Basis = Basis.looking_at(wish_dir)
		basis = basis.slerp(target, 0.15)
		#look_at(next_location) # Should make head look at next_location?
	
	if !is_on_floor():
		#wish_dir.y = 0
		velocity += get_gravity() * delta
	
	#var new_velocity = (next_location - position).normalized() * speewd
	#var new_velocity = rotation * speed
	#var new_velocity = transform.basis.z * speed
	var new_velocity = -transform.basis.z * speed
	# Need to clean up code, its running this twice
	if stop_moving:
		new_velocity = Vector3.ZERO
	velocity = velocity.lerp(new_velocity, 0.2)
	#velocity = velocity.lerp(new_velocity, 0.25)
	if not _snap_up_stairs_check(delta):
		move_and_slide()
	
	if attacking:
		for body in $AttackArea.get_overlapping_bodies():
			if body.has_method("take_damage") and body != self:
				body.take_damage(1)
				#print(body.hp)
