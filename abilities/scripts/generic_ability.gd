extends Node2D
class_name Ability

# WARNING: DO NOT USE THIS CLASS DIRECTLY!
# Attach a script of class Ability instead

@onready var cooldown_timer : Timer = $Cooldown
@onready var player : Node2D = get_parent()
@onready var parent_ship : RigidBody2D = player.get_node("Spaceship")

@export var ability_name : String = name

# function to activate the ability
# Don't overload this
func activate() -> bool:
	# Don't do anything if on cooldown
	if !cooldown_timer.is_stopped():
		return false

	_ability()
	cooldown_timer.start()
	return true
	


func _ability() -> void:
	# This function should be overloaded by the child class
	# to implement the specific ability logic
	push_warning("_ability() function not implemented in child class!")
