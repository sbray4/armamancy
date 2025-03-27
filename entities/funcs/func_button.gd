@tool
class_name FuncButton
extends AnimatableBody3D

@export var target: String = ""
@export var targetfunc: String = ""
#@export var targetname: String = ""
@export var move_pos: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
@export var speed: float = 3.0
@export var toggleable: bool = false
@export var interactable: bool = false

@export var mesh : MeshInstance3D

var highlight_material = preload("res://interactable_highlight.tres")
var looked_at := false :
	set(v):
		if v:
			# Highlight interactable
			mesh.material_overlay = highlight_material
		else:
			# Unhighlight interactable
			mesh.material_overlay = null
		looked_at = v

enum MoveStates {
	READY,
	MOVE
}
var move_state: MoveStates = MoveStates.READY
var move_progress: float = 0.0
var move_progress_target: float = 0.0
var sfx: AudioStreamPlayer3D

func _func_godot_apply_properties(props: Dictionary) -> void:
	target = props["target"] as String
	targetfunc = props["targetfunc"] as String
	#targetname = props["targetname"] as String
	move_pos[1] = GameManager.id_vec_to_godot_vec(props["move_pos"]) * GameManager.INVERSE_SCALE
	speed = props["speed"] as float
	toggleable = props["toggleable"] as bool
	interactable = props["interactable"] as bool

func mv_forward() -> void:
	move_progress_target = 1.0

func mv_reverse() -> void:
	move_progress_target = 0.0

func use() -> void:
	mv_forward()
	GAME.use_targets(self, target)
	if !toggleable:
		remove_from_group("interactable")

func _init() -> void:
	#add_to_group("interactable")
	sync_to_physics = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for child in get_children():
		if child is MeshInstance3D:
			mesh = child
	
	if interactable:
		add_to_group("interactable")
	
	#GAME.set_targetname(self, targetname)
	move_pos[0] = position
	move_pos[1] += move_pos[0]
	if speed > 0.0:
		speed = 1.0 / speed

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if move_progress != move_progress_target:
		if move_progress < move_progress_target:
			move_progress = minf(move_progress + speed * delta, move_progress_target)
		elif move_progress > move_progress_target:
			move_progress = maxf(move_progress - speed * delta, move_progress_target)
		if move_pos[0] != move_pos[1]:
			position = move_pos[0].lerp(move_pos[1], move_progress)
	if toggleable and move_progress == 1.0:
				mv_reverse()
