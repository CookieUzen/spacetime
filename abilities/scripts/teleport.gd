extends Ability

@export var teleport_distance: float = 100.0
@onready var hurtbox: CollisionPolygon2D = parent_ship.get_node("Hurtbox")
var pioneer: Area2D

func _ready() -> void:
	ability_name = "Teleport"
		
	pioneer = Area2D.new()
	# var pioneer := RigidBody2D.new()
	add_child(pioneer)

	var collisionShape: CollisionPolygon2D = hurtbox.duplicate()
	pioneer.add_child(collisionShape)

	# Toggle all the collision stuff
	pioneer.collision_mask = parent_ship.collision_mask
	pioneer.collision_layer = 0
	pioneer.monitoring = false
	pioneer.monitorable = false

func _ability() -> void:
	var teleport_vector = Vector2.UP.rotated(parent_ship.rotation) * teleport_distance
	var target_pos = parent_ship.global_position + teleport_vector

	# Move the pioneer to the right place
	pioneer.set_global_position(target_pos)
	pioneer.rotation = parent_ship.rotation
	pioneer.monitoring = true
	pioneer.monitorable = true

	# Create an area2d with the ship's CollisionPolygon2D and send it ahead
	await get_tree().physics_frame # Wait for move
	await get_tree().physics_frame # Wait for something else??? will break if removed

	# check if outside of the map
	# TODO: commented out because its broken.
	# var map = get_tree().get_first_node_in_group("Map")
	# target_pos = target_pos.clamp(
	# 	map.world_bounds.position,
	# 	map.world_bounds.position + map.world_bounds.size - Vector2(1, 1)
	# )

	# Don't teleport if we will teleport into something
	if pioneer.has_overlapping_bodies():
		return

	pioneer.monitoring = false
	parent_ship.set_global_position(target_pos)
