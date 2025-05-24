extends Node2D

const MAX_HP : float = 100.0
const MAX_SHIELD : float = 30.0
const SHIELD_REGEN : float = 4.0

const ARMOR : float = 0.8	# Armor coefficient, times all dmg by this value

signal shield_broken()	# When shield is broken
signal shield_regen()	# When shield starts regenerating
signal spaceship_destroyed()	# When hp is below 0

# hp
@export var hp : float;

# Shield system
@export var shield : float;
@onready var shield_regen_delay_timer: Timer = $ShieldRegenDelay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	hp = MAX_HP
	shield = MAX_SHIELD

	# reset the shield regen timer
	shield_regen_delay_timer.stop()
	# Catch the signal when the timer times out
	shield_regen_delay_timer.connect("timeout", _shield_regen)

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

	print(self.name, " got hit by ",  body, ": ", dmg)

	# Minus from the shield first
	var shield_after_dmg: float = shield - dmg

	if shield_after_dmg > 0:
		shield = shield_after_dmg
		dmg = 0.0
	else:
		dmg = -shield_after_dmg
		shield = 0.0

		# restart timer and emit signals
		_shield_broken()
	
	# Minus left over from the hp
	hp -= dmg


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

	return dmg

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Regenerate the shield if not been hit recently
	if shield_regen_delay_timer.time_left == 0:
		shield += SHIELD_REGEN * delta
		
	shield = clamp(shield, 0, MAX_SHIELD)

	if hp <= 0:
		_spaceship_destroyed()

# Runs when the shield is broken
func _shield_broken() -> void:
	shield_regen_delay_timer.start()
	print("Shield down!")

	emit_signal("shield_broken")

# Runs when the shield starts regenerating
func _shield_regen() -> void:
	print("Shield regenerating!")
	print("hp: ", hp)

	emit_signal("shield_regen")

# Runs when the hp is below 0
func _spaceship_destroyed() -> void:
	print("Ship destroyed!")

	emit_signal("spaceship_destroyed")
