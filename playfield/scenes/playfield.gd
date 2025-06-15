extends Node2D

@onready var player_scene: PackedScene = preload("res://players/scenes/player.tscn")
@onready var players: Node2D = $Players

var player_one: Node2D
var player_two: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Connect to the multiplayer new player signal
	multiplayer.connect("peer_connected", _on_player_joined)
	multiplayer.connect("peer_disconnected", _on_player_disconnect)
	Multiplayer.connect("clean_up", _on_player_disconnect) # emitted when joining/creating server
	Multiplayer.connect("new_server", _on_new_server) # emitted when joining/creating server

	$PlayerSpawner.spawn_function = _spawn_player

	if multiplayer.is_server():
		spawn_initial_players()
	
func _on_new_server(port: int) -> void:
	spawn_initial_players()

func spawn_initial_players() -> void:
	$PlayerSpawner.spawn(1)  # Spawn player one

func _spawn_player(peer_id: int) -> Node2D:

	var player := player_scene.instantiate() as Node2D
	var playerCount := GameState.player_count

	player.player_id = playerCount + 1
	player.player_input_mapping = "p" + str(player.player_id) + "_"	# p1_
	player.player_name = "Player " + str(player.player_id)	# Player 1
	player.peer_id = peer_id

	# delegate the player to the user
	player.set_multiplayer_authority(peer_id)

	return player


func _on_player_joined(player_id: int) -> void:
	print("Player joined with ID:", player_id)
	# This function is called when a new player joins the game
	if multiplayer.is_server():
		$PlayerSpawner.spawn(player_id)

func _on_player_disconnect(peer_id: int = 1) -> void:
	# This function is called when a player disconnects
	for player in players.get_children():
		if player.peer_id == peer_id:
			player.queue_free()
			break
