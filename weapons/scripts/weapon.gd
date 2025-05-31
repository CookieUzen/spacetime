extends Node2D
class_name Weapon

@onready var cooldown_timer := $Cooldown
@onready var player: Node2D = get_parent();
@onready var ship: RigidBody2D = player.get_node("Spaceship");
@onready var muzzle: Node2D = ship.get_node("Muzzle");
@onready var barrel: Node2D = muzzle.get_node("Barrel");

func on_hold() -> bool:
	# This function checks if the weapon can be fired
	if !cooldown_timer.is_stopped():
		return false
	
	if _on_hold() == false:
		return false

	cooldown_timer.start()
	return true

func on_release() -> void:
	# This function runs when the attack button is released
	return _on_release()

func _on_hold() -> bool:
	# This method should be overridden by subclasses
	push_error("Weapon::_on_hold() should be overridden by subclasses")
	return false

func _on_release() -> bool:
	# This method should be overridden by subclasses
	push_error("Weapon::_on_release() should be overridden by subclasses")
	return false
