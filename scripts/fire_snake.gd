extends CharacterBody2D

# Referencia al jugador
# Player reference
var player = null

# Velocidad de persecución
# Chase speed
const SPEED = 200.0

# Daño al contacto
# Contact damage
const DAMAGE = 40.0

# Duración máxima antes de desaparecer
# Max duration before disappearing
const LIFETIME = 8.0
var lifetime_timer: float = 0.0

# Temporizador de daño (para no dañar cada frame)
# Damage timer (to avoid damaging every frame)
const DAMAGE_COOLDOWN = 0.5
var damage_timer: float = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	lifetime_timer = LIFETIME

func _physics_process(delta):
	# Reducir temporizadores
	# Reduce timers
	lifetime_timer -= delta
	if damage_timer > 0:
		damage_timer -= delta

	# Destruir si se acaba el tiempo
	# Destroy if lifetime ends
	if lifetime_timer <= 0:
		queue_free()
		return

	if player == null:
		return

	# Perseguir al jugador
	# Chase player
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()

	# Dañar al jugador si está cerca
	# Damage player if close
	var dist = global_position.distance_to(player.global_position)
	if dist < 40.0 and damage_timer <= 0:
		if player.has_method("take_damage"):
			player.take_damage(DAMAGE)
			damage_timer = DAMAGE_COOLDOWN
			print("Serpiente de fuego daña al jugador / Fire snake damages player | Daño / Damage: ", DAMAGE)
