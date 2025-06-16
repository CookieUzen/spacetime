extends Node2D

@onready var player: Player = get_parent()
@onready var spaceship: RigidBody2D = player.get_node("Spaceship")


var p_in_map : String = "PLACEHOLDER-REPLACED-IN-_READY"	# Player input mapping

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the player input mapping from the parent
	p_in_map = player.player_input_mapping

	# Check if we are holding down weapon
	if Input.is_action_just_pressed(p_in_map+"fire_weapon"):
		spaceship.gun.on_hold()
	if Input.is_action_just_released(p_in_map+"fire_weapon"):
		spaceship.gun.on_release()

# For input handling

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Skip all input if we don't own the spaceship
	if player.peer_id != multiplayer.get_unique_id():
		return

	# Catch movement input 
	var turn_left:bool = Input.is_action_pressed(p_in_map + "turn_left");
	var turn_right:bool = Input.is_action_pressed(p_in_map + "turn_right");
	var forwards:bool = Input.is_action_pressed(p_in_map + "forward");
	var backwards:bool = Input.is_action_pressed(p_in_map + "back");
	var stop_damping:bool  = Input.is_action_pressed(p_in_map + "stop_damping");
	
	var input_dict: Dictionary = {
		"turn_left": turn_left,
		"turn_right": turn_right,
		"forwards": forwards,
		"backwards": backwards,
		"stop_damping": stop_damping
	}

	# Send the input to the spaceship
	spaceship.movement_input.rpc(input_dict)
