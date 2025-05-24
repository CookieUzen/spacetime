extends Node2D

const DMG_DIVISOR: float = 80000	# Divides KE by this amount
const MAX_FORCE: float = 500

@export var bolt_scene: PackedScene = preload("res://weapons/scenes/railgun_bolt.tscn")

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var charge_timer: Timer = $ChargeTimer

var current_bolt: RigidBody2D;
var ship: RigidBody2D;
var muzzle: Node2D;
var barrel: Node2D;

# Charges the railgun. Returns false if on cooldown
func charge() -> bool:
	# First check if we are on cooldown
	if !cooldown_timer.is_stopped():
		return false

	# make a new bolt
	current_bolt = bolt_scene.instantiate() as RigidBody2D
	if not current_bolt:
		push_error("Bolt instantiation failed!")
		return false
	
	# disable collision for the bolt when charging
	current_bolt.add_collision_exception_with(ship)

	# freeze the bolt to remove any physics calculations (we update the location manually)
	current_bolt.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	current_bolt.freeze = true

	# barrel.body_exited.connect(Callable(self, "_on_bolt_body_exited"))
	barrel.body_exited.connect(_on_bolt_body_exited.bind(current_bolt))

	# Add the bold to the scene
	add_child(current_bolt)

	# start the charge_timer
	charge_timer.start()

	return true

# Re-enable collision with the ship when the bolt is fired
func _on_bolt_body_exited(exited_body: Node, bolt: RigidBody2D) -> void:

	# only care about the barrel
	if exited_body != bolt:
		return

	# now safe to re-enable
	bolt.remove_collision_exception_with(ship)

	# disconnect so you don’t get called again
	barrel.body_exited.disconnect(_on_bolt_body_exited.bind(current_bolt))

# Fires the railgun. Returns false if not charged
func fire() -> void:
	if current_bolt == null:
		return

	# Calulate the force to apply
	var percentage_charged = 1 - charge_timer.time_left / charge_timer.wait_time
	var muzzle_dir = muzzle.global_transform.y.normalized() * -1
	var force = muzzle_dir * MAX_FORCE * percentage_charged

	# Undo the freeze mode
	current_bolt.freeze = false

	# tell the bolt to fire
	current_bolt.fire(force, DMG_DIVISOR)

	# add recoil to the ship
	ship.apply_impulse(force * -1)

	# remove the bolt reference
	current_bolt = null

	# Reset out timers
	cooldown_timer.start()
	charge_timer.stop()

func _ready() -> void:
	ship = get_parent().get_node("Spaceship")	# marker -> RigidBody2D
	muzzle = ship.get_node("Muzzle")	# RigidBody2D -> Railgun
	barrel = muzzle.get_node("Barrel")	# muzzle -> barrel

func _process(delta: float) -> void:

	# Keep the bolt in the same position as the ship
	if current_bolt:
		current_bolt.global_transform = muzzle.global_transform
