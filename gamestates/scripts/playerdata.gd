class_name PlayerData

@export var hp     : float
@export var shield : float
@export var max_hp : float = 100.0
@export var max_shield : float = 30.0
@export var player_id : int = 0
@export var player_name : String = ""
@export var player_input_mapping : String = ""

func _init(new_player_id: int, new_player_name: String, new_player_input_mapping,  max_hp_value: float = -1, max_shield_value: float = -1) -> void:
	max_hp = max_hp_value
	hp = max_hp

	max_shield = max_shield_value
	shield = max_shield

	player_id = new_player_id
	player_name = new_player_name
	player_input_mapping = new_player_input_mapping
