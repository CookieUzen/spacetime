extends RigidBody2D

signal hit(target: Node, impulse: float)	# hit by something, provides impulse vector

const THRUST_FORCE: float = 100000.0
const ROTATION_FORCE: float = 100000.0
const BRAKE_FORCE: float = 2.0
const RAMMING_DIVISOR: float = 3000	# Divides KE by this amount

var gun_scene: PackedScene
var gun: Node2D
@export var ramming_divisor: float = RAMMING_DIVISOR

func _ready() -> void:
	# Make a railgun and add it to our mount point
	gun_scene = preload("res://weapons/scenes/railgun.tscn")
	
	# create a gun and add it to the player (not ship)
	gun = gun_scene.instantiate() as Node2D
	call_deferred("add_sibling", gun)	# We need to defer here, 
										# because parent need to set up its own tree first

func _process(delta: float) -> void:
	# Check if we are holding down weapon
	if Input.is_action_just_pressed("fire_weapon"):
		gun.charge()
	if Input.is_action_just_released("fire_weapon"):
		gun.fire()


func _physics_process(delta: float) -> void:
	# movement calculations
	var rot_dir: float = 0;		# % of max rot force
	var thrust: float = 0;		# % of max thrust
	var thrustVec: Vector2 = Vector2.UP;	# store the thrust vector

	# Get user input:
	var turn_left:bool = Input.is_action_pressed("turn_left");
	var turn_right:bool = Input.is_action_pressed("turn_right");
	var forwards:bool = Input.is_action_pressed("forward");
	var backwards:bool = Input.is_action_pressed("back");
	var brake:bool  = Input.is_action_pressed("brake");

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
	if brake:
		linear_damp = BRAKE_FORCE
	else:
		linear_damp = 0


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
