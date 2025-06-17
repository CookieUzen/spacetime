extends Ability

@export var teleport_distance: float = 100.0

func _ready() -> void:
	ability_name = "Teleport"

func _ability() -> void:
	# calculate the vector to teleport
	var teleport_vector := Vector2.UP.rotated(parent_ship.rotation) * teleport_distance

	# Teleport!
	var new_position = parent_ship.global_position + teleport_vector
	var map := get_tree().get_first_node_in_group("Map")
	
	
	if map and not map.is_within_bounds(new_position):
		new_position = new_position.clamp(map.world_bounds.position, 
		map.world_bounds.position + map.world_bounds.size - Vector2(1, 1))
	
	parent_ship.call_deferred("set_global_position", new_position)
	
	
	
