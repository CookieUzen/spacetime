extends Node2D

const MAX_HP : float = 100.0
const MAX_SHIELD : float = 30.0
const SHIELD_REGEN : float = 4.0
const SHIELD_REGEN_DELAY : float = 5.0

const ARMOR : float = 0.8	# Armor coefficient, times all dmg by this value

# HP
@export var HP : float;

# Shield system
@export var SHIELD : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	HP = MAX_HP
	SHIELD = MAX_SHIELD

	# Listen for the player to be hit
	$Spaceship.connect("hit", _on_hit)

# Function to handle the hit event
func _on_hit(body: Node2D, ke: float) -> void:
	var dmg: float = 0.0

	# If hit by a projectile
	if body.is_in_group("Projectiles"):
		dmg = projectile_dmg_model(body, ke)
	# If hit by a spaceship
	elif body.is_in_group("Spaceships"):
		dmg = ship_dmg_model(body, ke)

	print(body, ": ", dmg)

# Function to calculate damage
# Accepts the body collided with and returns the damage dealt
func projectile_dmg_model(body: Node2D, ke: float) -> float:
	var dmg: float = 0.0

	dmg = ke / body.get("dmg_divisor") * ARMOR

	return dmg

func ship_dmg_model(body: Node2D, ke: float) -> float:
	var dmg: float = 0.0
	var ramming_divisor: float = 3000

	if body.get("ramming_divisor") != null:
		ramming_divisor = body.get("ramming_divisor")

	dmg = ke / ramming_divisor * ARMOR

	print("Ramming divisor: ", ramming_divisor)
	print("Damage: ", dmg)

	return dmg

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
