extends Node2D

@export var max_hp : float = 100.0
@export var max_shield : float = 30.0
@export var shield_regen_delay : float = 4.0

@export var player_id := 0;
@export var player_input_mapping := "";
@export var player_name := ""

@export var armor : float = 0.8	# Armor coefficient, times all dmg by this value

signal shield_broken()	# When shield is broken
signal shield_regen()	# When shield starts regenerating
signal spaceship_destroyed()	# When hp is below 0

# hp
@export var hp : float;

# Shield system
@export var shield : float;
@onready var shield_regen_delay_timer: Timer = $ShieldRegenDelay

# This runs before child's _ready()
func _enter_tree() -> void:
	# Sanity check
	if player_id == 0:
		print("Player ID not set, defaulting to 1")
		player_id = 1
	if player_input_mapping == "":
		print("Player input mapping not set, defaulting to p1_")
		player_input_mapping = "p1_"

	if player_name == "":
		print("Player name not set, defaulting to Player " + str(player_id))
		player_name = "Player " + str(player_id)
	
	# Register the player in the game state
	GameState.new_player(self)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	hp = max_hp
	shield = max_shield

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

	# Update the game state
	GameState.update_hp(player_id, hp)
	GameState.update_shield(player_id, shield)

# Function to calculate damage
# Accepts the body collided with and returns the damage dealt
func projectile_dmg_model(body: Node2D, ke: float) -> float:
	var dmg: float = 0.0

	dmg = ke / body.get("dmg_divisor") * armor

	return dmg

func ship_dmg_model(body: Node2D, ke: float) -> float:
	var dmg: float = 0.0
	var ramming_divisor: float = 3000

	if body.get("ramming_divisor") != null:
		ramming_divisor = body.get("ramming_divisor")

	dmg = ke / ramming_divisor * armor

	return dmg

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Regenerate the shield if not been hit recently
	if shield != max_shield && shield_regen_delay_timer.time_left == 0:
		shield += shield_regen_delay * delta
		GameState.update_shield(player_id, shield)
		
	shield = clamp(shield, 0, max_shield)

	if hp <= 0:
		_spaceship_destroyed()

# Runs when the shield is broken
func _shield_broken() -> void:
	shield_regen_delay_timer.start()
	emit_signal("shield_broken")

# Runs when the shield starts regenerating
func _shield_regen() -> void:
	emit_signal("shield_regen")

# Runs when the hp is below 0
func _spaceship_destroyed() -> void:
	print("Ship destroyed!")

	emit_signal("spaceship_destroyed")
