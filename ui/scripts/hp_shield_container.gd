extends MarginContainer

@export var hp: float
@export var shield: float

@export var max_hp: float
@export var max_shield: float

var hp_plus_shield: float
var max_hp_plus_shield: float

@onready var hp_bar: TextureProgressBar = $HPBar
@onready var shield_bar: TextureProgressBar = $ShieldBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Sanity check for hp and shield
	hp = clampf(hp, 0, max_hp)
	shield = clampf(shield, 0, max_shield)

	# Calculate variables for shield bars
	max_hp_plus_shield = max_hp + max_shield
	hp_plus_shield = hp + shield

	# Update max values
	hp_bar.max_value = max_hp_plus_shield
	shield_bar.max_value = max_hp_plus_shield

	# Update bar values
	hp_bar.value = hp
	shield_bar.value = hp_plus_shield
