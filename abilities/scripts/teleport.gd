extends Ability

@export var teleport_distance: float = 100.0

func _ready() -> void:
	ability_name = "Teleport"

func _ability() -> void:
	# calculate the vector to teleport
	var teleport_vector := Vector2.UP.rotated(parent_ship.rotation) * teleport_distance

	# Teleport!
	parent_ship.call_deferred("set_global_position", parent_ship.global_position + teleport_vector)
	
