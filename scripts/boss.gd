extends CharacterBody2D

# Nivel del jefe
# Boss level
@export var enemy_level: int = 100

# Vida
# Health
var health: float = 1000.0
const HEALTH_MAX: float = 1000.0

# Fase actual (1 o 2)
# Current phase (1 or 2)
var phase: int = 1

# Referencia al jugador
# Player reference
var player = null

# Temporizador de parpadeo de daño
# Damage blink timer
var blink_timer: float = 0.0

# Velocidad de movimiento
# Movement speed
const SPEED = 100.0

# --- ATAQUE A DISTANCIA ---
# --- RANGED ATTACK ---
const FIRE_RATE_P1 = 2.0       # cadencia fase 1 / fire rate phase 1
const FIRE_RATE_P2 = 1.0       # cadencia fase 2 / fire rate phase 2
const BULLET_DAMAGE = 20.0
var fire_timer: float = 0.0

# Distancia para ataque cuerpo a cuerpo
# Melee attack distance
const MELEE_RANGE = 80.0
const MELEE_DAMAGE = 35.0
const MELEE_COOLDOWN = 1.5
var melee_timer: float = 0.0

# --- INVOCACIÓN ---
# --- SUMMON ---
const SUMMON_COOLDOWN_P1 = 15.0   # segundos entre invocaciones fase 1 / seconds between summons phase 1
const SUMMON_COOLDOWN_P2 = 8.0    # segundos entre invocaciones fase 2 / seconds between summons phase 2
var summon_timer: float = 0.0
const MAX_SUMMONS = 3              # máximo de subordinados activos / max active summons

# --- SERPIENTE DE FUEGO (fase 2) ---
# --- FIRE SNAKE (phase 2) ---
const SNAKE_COOLDOWN = 12.0
var snake_timer: float = 0.0

# Tabla de modificadores por nivel
# Level modifier table
const LEVEL_MODIFIERS = [
	[1,   50,  0.6, 1.5],
	[51,  89,  1.0, 1.0],
	[90,  99,  1.2, 0.8],
	[100, 999, 1.5, 0.6],
]

func _ready():
	player = get_tree().get_first_node_in_group("player")
	fire_timer = FIRE_RATE_P1
	summon_timer = SUMMON_COOLDOWN_P1

func _physics_process(delta):
	if player == null:
		return

	# Gestionar parpadeo
	# Handle blink
	if blink_timer > 0:
		blink_timer -= delta

	# Comprobar cambio de fase
	# Check phase change
	if phase == 1 and health <= HEALTH_MAX * 0.25:
		_enter_phase_2()

	var dist = global_position.distance_to(player.global_position)

	# Moverse hacia el jugador si está lejos
	# Move towards player if far
	if dist > MELEE_RANGE:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Ataque cuerpo a cuerpo
	# Melee attack
	melee_timer -= delta
	if dist <= MELEE_RANGE and melee_timer <= 0:
		_melee_attack()
		melee_timer = MELEE_COOLDOWN

	# Ataque a distancia
	# Ranged attack
	fire_timer -= delta
	if dist > MELEE_RANGE and fire_timer <= 0:
		_fire()
		fire_timer = FIRE_RATE_P1 if phase == 1 else FIRE_RATE_P2

	# Invocación
	# Summon
	summon_timer -= delta
	if summon_timer <= 0:
		_summon()
		summon_timer = SUMMON_COOLDOWN_P1 if phase == 1 else SUMMON_COOLDOWN_P2

	# Serpiente de fuego (solo fase 2)
	# Fire snake (phase 2 only)
	if phase == 2:
		snake_timer -= delta
		if snake_timer <= 0:
			_launch_fire_snake()
			snake_timer = SNAKE_COOLDOWN

func _enter_phase_2():
	phase = 2
	print("Jefe fase 2 / Boss phase 2")
	# Invocación inmediata al entrar en fase 2
	# Immediate summon on phase 2 entry
	_summon()
	snake_timer = 3.0  # primera serpiente a los 3 segundos / first snake after 3 seconds

func _fire():
	# Disparar proyectil con ligero homing hacia el jugador
	# Fire bullet with slight homing towards player
	var bullet = preload("res://scenes/enemy_bullet.tscn").instantiate()
	bullet.global_position = global_position
	var dir = (player.global_position - global_position).normalized()
	bullet.setup(dir, BULLET_DAMAGE)
	get_parent().add_child(bullet)

func _melee_attack():
	# Golpe en área cercana
	# Close range area hit
	if player.has_method("take_damage"):
		player.take_damage(MELEE_DAMAGE)
		print("Jefe golpe cuerpo a cuerpo / Boss melee hit | Daño / Damage: ", MELEE_DAMAGE)

func _summon():
	# Comprobar que no hay demasiados subordinados
	# Check max summons not exceeded
	var current_summons = get_tree().get_nodes_in_group("enemy").size()
	if current_summons >= MAX_SUMMONS + 1:  # +1 porque el jefe también está en el grupo / +1 because boss is also in group
		return
	# Invocar un Arrastrado cerca del jefe
	# Summon a Crawler near the boss
	var summon = preload("res://scenes/enemy.tscn").instantiate()
	summon.global_position = global_position + Vector2(randf_range(-150, 150), randf_range(-150, 150))
	summon.enemy_level = randi_range(75, 90)
	get_parent().add_child(summon)
	print("Jefe invoca subordinado nivel / Boss summons minion level: ", summon.enemy_level)

func _launch_fire_snake():
	# Lanzar serpiente de fuego que persigue al jugador
	# Launch fire snake that chases player
	var snake = preload("res://scenes/fire_snake.tscn").instantiate()
	snake.global_position = global_position
	get_parent().add_child(snake)
	print("Jefe lanza serpiente de fuego / Boss launches fire snake")

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
	print("Jefe vida / Boss health: ", health, " | Daño / Damage: ", final_damage)
	if health <= 0:
		die()

func die():
	print("Jefe muerto / Boss dead")
	# 25% de probabilidad de soltar habilidad
	# 25% chance to drop skill
	if randf() <= 0.25:
		print("Habilidad disponible para robar / Skill available to steal: fire_snake")
		# TODO: implementar pantalla de robo de habilidad
	queue_free()
