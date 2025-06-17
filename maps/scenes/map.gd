extends Node2D

var spawn_points := [];

func _ready() -> void:
	# Get spawn points
	for child in get_children():
		if child is Marker2D && child.name.contains("Spawnpoint"):
			spawn_points.append(child)

	# Connect to the GameState signal
	GameState.connect("player_added", _move_player_to_spawn)

func _move_player_to_spawn(player_id: int) -> void:
	print("Moving player to spawn point:", player_id)
	var player: Node2D = GameState.players[player_id - 1]
	player.position = spawn_points[(player_id - 1) % spawn_points.size()].position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
