extends Node2D

@onready var player_scene: PackedScene = preload("res://players/scenes/player.tscn")

var player_one: Node2D
var player_two: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	player_one = player_scene.instantiate() as Node2D
	player_one.player_id = 1
	player_one.player_input_mapping = "p1_"
	player_one.player_name = "Player 1"
	add_child(player_one)

	player_two = player_scene.instantiate() as Node2D
	player_two.player_id = 2
	player_two.player_input_mapping = "p2_"
	player_two.player_name = "Player 2"
	add_child(player_two)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
