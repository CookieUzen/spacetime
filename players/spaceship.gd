extends RigidBody2D

const THRUST_FORCE: float = 100000.0
const ROTATION_FORCE: float = 100000.0
const BRAKE_FORCE: float = 2.0

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
