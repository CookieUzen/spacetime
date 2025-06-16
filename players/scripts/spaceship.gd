extends RigidBody2D

signal hit(target: Node, impulse: float)	# hit by something, provides impulse vector

const DEFAULT_DAMPING: float = 1
const DEFAULT_ANGLAR_DAMPING: float = 1
const THRUST_FORCE: float = 100000.0 * DEFAULT_DAMPING	# Force applied to the ship when moving
const ROTATION_FORCE: float = 100000.0	* DEFAULT_ANGLAR_DAMPING	# Force applied to the ship when turning
const RAMMING_DIVISOR: float = 3000	# Divides KE by this amount

var gun_scene: PackedScene
var gun: Node2D
@export var ramming_divisor: float = RAMMING_DIVISOR

var p_in_map : String = "PLACEHOLDER-REPLACED-IN-_READY"	# Player input mapping

@onready var self_player: Player = get_parent()	# Get the parent player node

# For input handling
var turn_left:bool
var turn_right:bool
var forwards:bool
var backwards:bool
var stop_damping:bool 

# any one can call this rpc (ie client can move)
# can be called locally (move the spaceship locally as well)
# reliable, packets in order (skip late arriving packets)
# channel 1 for inputs
@rpc("any_peer", "call_local", "unreliable_ordered", 1)
func movement_input(input_dict: Dictionary) -> void:
	# make sure the correct player is calling
	var caller_id := multiplayer.get_remote_sender_id()
	for player in GameState.player_data:
		# Find the current player
		if player.player_id != self_player.player_id:
			continue

		# Check if the caller id matches the peer id
		if player.peer_id != caller_id:
			push_warning("Player ID mismatch: ", player.player_id, " vs ", self_player.player_id, ". Input ignored")
			return

		# caller id matches, which means the correct client is calling this function
		break

	# Update the input variables based on the input dictionary
	turn_left = input_dict.get("turn_left", false)
	turn_right = input_dict.get("turn_right", false)
	forwards = input_dict.get("forwards", false)
	backwards = input_dict.get("backwards", false)
	stop_damping = input_dict.get("stop_damping", false)

	print("Input received from player ", self_player.player_id, ": ", input_dict)

func reset_input() -> void:
	# Reset the input variables
	turn_left = false
	turn_right = false
	forwards = false
	backwards = false
	stop_damping = false

func _ready() -> void:
	# Reset input
	reset_input()

	# Make a railgun and add it to our mount point
	gun_scene = preload("res://weapons/scenes/railgun.tscn")
	
	# create a gun and add it to the player (not ship)
	gun = gun_scene.instantiate() as Node2D
	call_deferred("add_sibling", gun)	# We need to defer here, 
										# because parent need to set up its own tree first

func _physics_process(delta: float) -> void:
	# movement calculations
	var rot_dir: float = 0;		# % of max rot force
	var thrust: float = 0;		# % of max thrust
	var thrustVec: Vector2 = Vector2.UP;	# store the thrust vector

	if turn_left:
		rot_dir -= 1;
	if turn_right:
		rot_dir += 1;
	if forwards:
		thrust += 1;
	if backwards:
		thrust -= 1;

	# rotate the vector to point in the direction of the ship
	thrustVec = thrustVec.rotated(rotation)	 * thrust

	apply_torque(rot_dir * delta * ROTATION_FORCE) 			# Turn ship
	apply_central_force(thrustVec * THRUST_FORCE * delta) 	# propel ship

	# brake
	if stop_damping:
		linear_damp = 0
		angular_damp = 0 
	else:
		linear_damp = DEFAULT_DAMPING
		angular_damp = DEFAULT_ANGLAR_DAMPING

	# Consume the input (for now)
	# TODO: add some sort of guessing if we are missing inputs
	reset_input()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:

	var hit_by_arr: Array = []

	# calculate collision kinetic energy
	for i in state.get_contact_count():

		var hit_by := state.get_contact_collider_object(i)

		# Don't count the same object twice
		if hit_by_arr.has(hit_by):
			continue

		hit_by_arr.append(hit_by)

		var rel_v := linear_velocity - state.get_contact_collider_velocity_at_position(i)
		var ke    := 0.5 * mass * rel_v.length_squared()

		emit_signal("hit", hit_by, ke)
