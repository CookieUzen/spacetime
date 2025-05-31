extends CanvasLayer

@onready var hp_shield_container: PackedScene = preload("res://ui/scenes/hp_shield_container.tscn")

var hp_shield_instances: Array[MarginContainer] = []

func _ready() -> void:
	# listen for player_added signal from GameState
	GameState.connect("player_added", _new_bar)

	# Listen for hp/shield updates
	GameState.connect("hp_updated", _on_hp_updated)
	GameState.connect("shield_updated", _on_shield_updated)

func _on_hp_updated(player_id: int, hp: float) -> void:
	# Update the HP bar for the player
	hp_shield_instances[player_id - 1].hp = hp

func _on_shield_updated(player_id: int, shield: float) -> void:
	# Update the Shield bar for the player
	hp_shield_instances[player_id - 1].shield = shield

func _new_bar(player_id: int) -> void:
	# Create a new HP/Shield container for each player
	var player: PlayerData = GameState.player_data[player_id - 1]
	var hp_shield_instance := hp_shield_container.instantiate() as MarginContainer

	# Set the player data for the HP/Shield container
	hp_shield_instance.name = player.player_input_mapping + "HPShield"
	hp_shield_instance.hp = player.hp
	hp_shield_instance.shield = player.shield
	hp_shield_instance.max_hp = player.max_hp
	hp_shield_instance.max_shield = player.max_shield

	# Move the HP/Shield container to the correct position
	if player_id == 0:
		hp_shield_instance.anchor_left = 0
		hp_shield_instance.anchor_right = 0
		hp_shield_instance.anchor_top = 0
		hp_shield_instance.anchor_bottom = 0
	elif player_id == 1:
		hp_shield_instance.anchor_left   = 1
		hp_shield_instance.anchor_right  = 1
		hp_shield_instance.anchor_top    = 0
		hp_shield_instance.anchor_bottom = 0

		# Flip the HP/Shield container for player 2
		hp_shield_instance.scale = Vector2(-1, 1)

	hp_shield_instances.append(hp_shield_instance)
	add_child(hp_shield_instance)
