@tool
class_name FuncMove
extends AnimatableBody3D

@export var targetname: String = ""
@export var move_pos: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
@export var move_rot: Vector3 = Vector3.ZERO
@export var speed: float = 3.0
@export var toggleable: bool = false
@export var interactable: bool = false
@export var key: int = 0

@export var mesh : MeshInstance3D

var highlight_material = preload("res://interactable_highlight.tres")
var looked_at := false :
	set(v):
		if v:
			# Highlight interactable
			mesh.material_overlay = highlight_material
			# If door requires a key
			if key:
				# Check if player doesn't have the key
				if !(GAME.player.keys & (1 << (key - 1))):
					# Display locked door message
					GAME.message_label.text = "You need the " + GAME.keyNames[key - 1] + " to unlock this door."
					GAME.message_panel.visible = true
		else:
			# Unhighlight interactable
			mesh.material_overlay = null
			# Hide message box, maybe I should check it even needs a key?
			GAME.message_panel.visible = false
			GAME.message_label.text = ""
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
	targetname = props["targetname"] as String
	move_pos[1] = GameManager.id_vec_to_godot_vec(props["move_pos"]) * GameManager.INVERSE_SCALE
	if props["move_rot"] is Vector3:
		var r: Vector3 = props["move_rot"]
		for i in 3:
			move_rot[i] = deg_to_rad(r[i])
	speed = props["speed"] as float
	toggleable = props["toggleable"] as bool
	interactable = props["interactable"] as bool
	key = props["key"] as int

func mv_forward() -> void:
	move_progress_target = 1.0

func mv_reverse() -> void:
	move_progress_target = 0.0

func use() -> void:
	if key:
		if !(GAME.player.keys & key):
			#print("You need the " + GAME.get_key_name(key) + " to open this door")
			return
	if toggleable:
		toggle()
	else:
		mv_forward()
		remove_from_group("interactable")

func toggle() -> void:
	if move_progress_target > 0.0:
		mv_reverse()
	else:
		mv_forward()

func _init() -> void:
	add_to_group("func_move")
	sync_to_physics = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	for child in get_children():
		if child is MeshInstance3D:
			mesh = child
	
	if interactable:
		add_to_group("interactable")
	
	GAME.set_targetname(self, targetname)
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
		if move_rot != Vector3.ZERO:
			rotation = Vector3.ZERO.lerp(move_rot, move_progress)
