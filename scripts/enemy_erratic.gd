extends CharacterBody2D

# Nivel del enemigo
# Enemy level
@export var enemy_level: int = 30

# Vida
# Health
var health: float = 100.0

# Temporizador de parpadeo de daño
# Damage blink timer
var blink_timer: float = 0.0

# Referencia al jugador
# Player reference
var player = null

# Velocidad de movimiento caótico
# Chaotic movement speed
const SPEED = 180.0

# Temporizador de cambio de dirección
# Direction change timer
var move_timer: float = 0.0
const MOVE_TIME_MIN = 0.3
const MOVE_TIME_MAX = 0.8

# Dirección actual de movimiento
# Current movement direction
var move_direction: Vector2 = Vector2.ZERO

# Temporizador de disparo
# Fire timer
var fire_timer: float = 0.0
var burst_count: int = 0        # balas disparadas en la ráfaga actual / bullets fired in current burst
const BURST_SIZE = 3            # balas por ráfaga / bullets per burst
const BURST_DELAY = 0.15        # segundos entre balas de la ráfaga / seconds between burst bullets
const BURST_PAUSE = 2.0         # pausa entre ráfagas / pause between bursts
var in_burst: bool = false      # si está en medio de una ráfaga / if currently in a burst

# Distancia máxima para disparar
# Max distance to shoot
const SHOOT_RANGE = 500.0

# Tabla de modificadores por nivel (igual que los otros enemigos)
# Level modifier table (same as other enemies)
const LEVEL_MODIFIERS = [
	[1,   50,  0.6, 1.5],
	[51,  89,  1.0, 1.0],
	[90,  99,  1.2, 0.8],
	[100, 999, 1.5, 0.6],
]

func _ready():
	player = get_tree().get_first_node_in_group("player")
	# Empezar con dirección aleatoria
	# Start with random direction
	_new_direction()
	fire_timer = BURST_PAUSE

func _physics_process(delta):
	if player == null:
		return

	# Gestionar parpadeo de daño
	# Handle damage blink
	if blink_timer > 0:
		blink_timer -= delta

	# Movimiento caótico: cambiar dirección cada cierto tiempo
	# Chaotic movement: change direction every so often
	move_timer -= delta
	if move_timer <= 0:
		_new_direction()

	velocity = move_direction * SPEED
	move_and_slide()

	# Gestionar disparo en ráfagas
	# Handle burst shooting
	fire_timer -= delta
	var dist = global_position.distance_to(player.global_position)

	if fire_timer <= 0 and dist <= SHOOT_RANGE:
		if not in_burst:
			# Iniciar nueva ráfaga
			# Start new burst
			in_burst = true
			burst_count = 0
		if burst_count < BURST_SIZE:
			_fire()
			burst_count += 1
			fire_timer = BURST_DELAY
		else:
			# Ráfaga terminada, esperar pausa
			# Burst finished, wait for pause
			in_burst = false
			fire_timer = BURST_PAUSE

func _new_direction():
	# Dirección aleatoria con componente hacia el jugador
	# Random direction with component towards player
	var random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	if player:
		var to_player = (player.global_position - global_position).normalized()
		# Mezclar dirección aleatoria con dirección al jugador (30% hacia jugador)
		# Mix random direction with player direction (30% towards player)
		move_direction = (random_dir * 0.7 + to_player * 0.3).normalized()
	else:
		move_direction = random_dir
	move_timer = randf_range(MOVE_TIME_MIN, MOVE_TIME_MAX)

func _fire():
	# Disparar proyectil hacia el jugador con ligera dispersión
	# Fire bullet towards player with slight spread
	var bullet = preload("res://scenes/enemy_bullet.tscn").instantiate()
	bullet.global_position = global_position
	var base_dir = (player.global_position - global_position).normalized()
	# Añadir dispersión aleatoria a la ráfaga
	# Add random spread to burst
	var spread = randf_range(-0.2, 0.2)
	var perp = Vector2(-base_dir.y, base_dir.x)
	var final_dir = (base_dir + perp * spread).normalized()
	bullet.setup(final_dir, 12.0)
	get_parent().add_child(bullet)

func get_modifiers() -> Dictionary:
	for m in LEVEL_MODIFIERS:
		if enemy_level >= m[0] and enemy_level <= m[1]:
			return {"dmg_out": m[2], "dmg_in": m[3]}
	return {"dmg_out": 1.0, "dmg_in": 1.0}

func take_damage(raw_damage: float):
	var mod = get_modifiers()
	var final_damage = raw_damage * mod["dmg_in"]
	health -= final_damage
	blink_timer = 0.3
	print("Errático nivel / Erratic level: ", enemy_level, " | Daño / Damage: ", final_damage)
	if health <= 0:
		die()

func die():
	# Morir — los portales son fijos en el escenario, no se generan aquí
	# Die — portals are fixed in the scene, not spawned here
	print("Errático muerto / Erratic dead")
	queue_free()
