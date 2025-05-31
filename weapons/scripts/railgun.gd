extends Weapon

@export var dmg_divisor: float = 80000	# Divides KE by this amount
@export var max_force: float = 500

@export var bolt_scene: PackedScene = preload("res://weapons/scenes/railgun_bolt.tscn")

@onready var charge_timer: Timer = $ChargeTimer

var current_bolt: RigidBody2D;

# Charges the railgun. Returns false if on cooldown
func _on_hold() -> bool:

	# make a new bolt
	current_bolt = bolt_scene.instantiate() as RigidBody2D
	if not current_bolt:
		push_error("Bolt instantiation failed!")
		return false
	
	# disable collision for the bolt when charging
	for ships in GameState.players:
		current_bolt.add_collision_exception_with(ships.get_node("Spaceship"))

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
	for ships in GameState.players:
		# re-enable collision with the ship
		bolt.remove_collision_exception_with(ships.get_node("Spaceship"))

	# disconnect so you don’t get called again
	barrel.body_exited.disconnect(_on_bolt_body_exited.bind(current_bolt))

# Fires the railgun. Returns false if not charged
func _on_release() -> bool:
	if current_bolt == null:
		return false

	# Calulate the force to apply
	var percentage_charged = get_charge_pct(charge_timer, 0.3, 8.0)
	var muzzle_dir = muzzle.global_transform.y.normalized() * -1
	var force = muzzle_dir * max_force * percentage_charged

	# Undo the freeze mode
	current_bolt.freeze = false

	# tell the bolt to _on_release
	current_bolt.fire(force, dmg_divisor)

	# add recoil to the ship
	ship.apply_impulse(force * -1)

	# remove the bolt reference
	current_bolt = null

	# Reset out timers
	charge_timer.stop()

	return true

# 0 ≤ center ≤ 1  :  where you want the knee
# steepness (k)   :  how sharp the knee feels
func get_charge_pct(timer: Timer, center := 0.5, steepness := 10.0) -> float:
	# Linear 0‒1 progress (what you had).
	var t := 1.0 - timer.time_left / timer.wait_time	  # elapsed / wait_time

	# Logistic sigmoid, centred at 0.5.
	#	  f(t) = 1 / (1 + e^(-k (t-0.5)))
	# 'steepness' k controls how “sharp” the knee is.
	var s := 1.0 / (1.0 + exp(-steepness * (t - center)))

	return clamp(s, 0.0, 1.0)

func _process(delta: float) -> void:

	# Keep the bolt in the same position as the ship
	if current_bolt:
		current_bolt.global_transform = muzzle.global_transform
