extends CharacterBody2D

# Nivel del enemigo
# Enemy level
@export var enemy_level = 30

# Vida
# Health
var health: float = 100.0

# Temporizadores
# Timers
var blink_timer: float = 0.0
var fire_timer: float = 0.0

# Referencia al jugador
# Player reference
var player = null

# Distancias de zona segura
# Safe zone distances
const DIST_MIN = 200.0
const DIST_MAX = 380.0
const SPEED = 120.0

# Cadencia de disparo y daño del proyectil
# Fire rate and bullet damage
const FIRE_RATE = 2.0
const BULLET_DAMAGE = 15.0

# Tabla de modificadores por nivel (igual que enemy.gd)
# Level modifier table (same as enemy.gd)
const LEVEL_MODIFIERS = [
	[1,   50,  0.6, 1.5],
	[51,  89,  1.0, 1.0],
	[90,  99,  1.2, 0.8],
	[100, 999, 1.5, 0.6],
]

func _ready():
	player = get_tree().get_first_node_in_group("player")
	# Empieza con el timer lleno para no disparar al instante
	# Start with full timer to avoid instant shot on spawn
	fire_timer = FIRE_RATE

func _physics_process(delta):
	if player == null:
		return

	# Gestionar parpadeo de daño
	# Handle damage blink
	if blink_timer > 0:
		blink_timer -= delta

	# Reducir temporizador de disparo
	# Reduce fire timer
	fire_timer -= delta

	var dist = global_position.distance_to(player.global_position)

	if dist < DIST_MIN:
		# Demasiado cerca: retroceder
		# Too close: back away
		var dir = (global_position - player.global_position).normalized()
		velocity = dir * SPEED
	elif dist > DIST_MAX:
		# Demasiado lejos: acercarse
		# Too far: move closer
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * SPEED
	else:
		# Zona segura: detenerse y disparar
		# Safe zone: stop and shoot
		velocity = Vector2.ZERO
		if fire_timer <= 0:
			_fire()
			fire_timer = FIRE_RATE

	move_and_slide()

func _fire():
	# Instanciar proyectil y apuntar al jugador
	# Instantiate bullet and aim at player
	var bullet = preload("res://scenes/enemy_bullet.tscn").instantiate()
	bullet.global_position = global_position
	var dir = (player.global_position - global_position).normalized()
	bullet.setup(dir, BULLET_DAMAGE)
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
	print("Acechador nivel / Stalker level: ", enemy_level, " | Daño / Damage: ", final_damage)
	if health <= 0:
		die()

func die():
	# Morir — los portales son fijos en el escenario, no se generan aquí
	# Die — portals are fixed in the scene, not spawned here
	print("Acechador muerto / Stalker dead")
	queue_free()
