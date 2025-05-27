extends Node2D

var players: Array[Node2D] = []
var player_data: Array[PlayerData] = []
var player_count: int = 0

signal hp_updated(player_id: int, hp: float)
signal shield_updated(player_id: int, hp: float)
signal player_added(player_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func new_player(player: Node2D) -> void:
	# Add the player to the players array
	players.append(player)
	player_data.append(PlayerData.new(player.player_id, player.player_name, player.player_input_mapping, player.max_hp, player.max_shield))
	player_count += 1

	emit_signal("player_added", player.player_id)

func update_hp(player_id: int, hp: float) -> void:
	if player_id <= 0 or player_id > player_count:
		print("Invalid player ID:", player_id)
		return
	
	player_data[player_id-1].hp = hp
	emit_signal("hp_updated", player_id, hp)

func update_shield(player_id: int, shield: float) -> void:
	if player_id <= 0 or player_id > player_count:
		print("Invalid player ID:", player_id)
		return
	
	player_data[player_id-1].shield = shield
	emit_signal("shield_updated", player_id, shield)
