extends CharacterBody2D

@onready var move_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get('parameters/MoveStateMachine/playback')
@onready var tool_state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get('parameters/ToolStateMachine/playback')

var direction : Vector2
var last_direction : Vector2
var speed := 300
var can_move := true
signal tool_use(tool :Tools, pos: Vector2)
enum Tools {HOE, AXE, WATER}
var current_tool = Tools.AXE
var tool_direction_offset : int = 12
var tool_y_offset : int = 4

const tool_connection = {
	Tools.HOE: 'hoe',
	Tools.AXE: 'axe',
	Tools.WATER: 'water',
	
}
func _physics_process(delta: float) -> void:
	if can_move:
		get_input()
	if direction:
		last_direction = direction
	velocity = direction * speed * int(can_move)
	move_and_slide()
	animation()
	
func _ready() -> void:
	pass


func get_input():
	direction = Input.get_vector("left","right","up","down")
	
	if Input.is_action_just_pressed('action'):
		print("--- STEP 1: Action Pressed. Current Tool is: ", current_tool)
		tool_state_machine.travel(tool_connection[current_tool])
		$AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		can_move = false
		await $AnimationTree.animation_finished
		print("--- STEP 2: Animation finished. Emitting signal...")
		tool_use.emit(current_tool, position + last_direction * tool_direction_offset + Vector2(0,tool_y_offset))
		
	if Input.is_action_just_pressed("tool_forward"):
		current_tool = (current_tool + 1) % Tools.size() as Tools
		print("Selected Tool: ", current_tool)
	elif Input.is_action_just_pressed("tool_backward"):
		current_tool = (current_tool - 1 + Tools.size()) % Tools.size() as Tools
		print("Selected Tool: ", current_tool)

func animation():
	if direction:
		move_state_machine.travel('move')
		var target_vector : Vector2 = Vector2(round(direction.x),round(direction.y))
		$AnimationTree.set("parameters/MoveStateMachine/move/blend_position", target_vector)
		$AnimationTree.set("parameters/MoveStateMachine/idle/blend_position", target_vector)
		for state in tool_connection.values():
			$AnimationTree.set("parameters/ToolStateMachine/"+ state +"/blend_position", target_vector)
		
		
	else:
		move_state_machine.travel('idle')


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	can_move = true
