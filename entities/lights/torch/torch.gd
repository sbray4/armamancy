@tool
class_name LightTorch
extends Node3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(%OmniLight3D, props)
	%OmniLight3D.omni_range = (props["range"] as float) * GameManager.INVERSE_SCALE
	# The overriding color thing doesn't seem to work, probably because the light is a child of a scene
	# It's safe to assume all the properties of the light don't work?
