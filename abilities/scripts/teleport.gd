extends Ability

@export var teleport_distance: float = 100.0
@onready var front_check = parent_ship.get_node("Pioneer") as CharacterBody2D
var _is_front_blocked := false

func _ready() -> void:
	ability_name = "Teleport"
		
#func position_is_valid() -> bool:
	#print(front_check.global_position)
	#print(front_check.get_overlapping_areas())
	#print(front_check.get_overlapping_bodies())
	#await get_tree().physics_frame
	#return not _is_front_blocked
	
func _ability() -> void:
	await get_tree().physics_frame 

	var teleport_vector = Vector2.UP.rotated(parent_ship.rotation) * teleport_distance
	var map = get_tree().get_first_node_in_group("Map")

	var target_pos = parent_ship.global_position + teleport_vector
	target_pos = target_pos.clamp(
		map.world_bounds.position,
		map.world_bounds.position + map.world_bounds.size - Vector2(1, 1)
	)

	#if await position_is_valid():
		#print("VALID!!")
		#
	#else:
		#print("INVALID!")
		
	parent_ship.call_deferred("set_global_position", target_pos)

	
	
