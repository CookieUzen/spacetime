extends RigidBody2D

@export var lifetime: float = 10.0
@export var dmg_divisor: float = 1.0
@export var in_motion: bool = false

# Fire the bolt with a force and damage coefficient
func fire(force: Vector2, damage_divisor: float) -> void:
	# get rid of angular momentum: don't want the bolt to spin
	self.angular_velocity = 0
	self.dmg_divisor = damage_divisor

	# apply the force to the bolt
	apply_impulse(force)
	in_motion = true

func _process(delta: float) -> void:
	# Clean up the bolt after a certain amount of time
	if in_motion:
		lifetime -= delta

	if lifetime <= 0:
		queue_free()

# TODO: When auto garbage collect after hitting something
