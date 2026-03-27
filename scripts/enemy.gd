extends CharacterBody2D

# Nivel del enemigo
# Enemy level
@export var enemy_level = 30

# Vida del enemigo
# Enemy health
var health = 100.0

# Velocidad del enemigo
# Enemy speed
const SPEED = 150.0

# Referencia al jugador
# Player reference
var player = null

# Tabla de modificadores por nivel
# Level modifier table
const LEVEL_MODIFIERS = [
	# [nivel_min, nivel_max, dmg_dado, dmg_recibido]
	[1,   50,  0.6, 1.5],
	[51,  89,  1.0, 1.0],
	[90,  99,  1.2, 0.8],
	[100, 999, 1.5, 0.6],
]

func _ready():
	# Buscar al jugador en la escena
	# Find player in scene
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	# Si no hay jugador no hacer nada
	# If no player do nothing
	if player == null:
		return

	# Moverse hacia el jugador
	# Move towards player
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()

func get_modifiers() -> Dictionary:
	# Obtener modificadores según nivel
	# Get modifiers by level
	for m in LEVEL_MODIFIERS:
		if enemy_level >= m[0] and enemy_level <= m[1]:
			return {"dmg_out": m[2], "dmg_in": m[3]}
	return {"dmg_out": 1.0, "dmg_in": 1.0}

func take_damage(raw_damage: float):
	var mod = get_modifiers()
	var final_damage = raw_damage * mod["dmg_in"]
	health -= final_damage
	print("Nivel / Level: ", enemy_level, " | Modificador / Modifier: ", mod["dmg_in"], " | Daño / Damage: ", final_damage)
	if health <= 0:
		die()

func die():
	# Morir
	# Die
	print("Enemigo muerto / Enemy dead")
	
	# Generar portal al morir
	# Spawn portal on death
	var portal = preload("res://scenes/portal.tscn").instantiate()
	portal.global_position = global_position
	get_parent().add_child(portal)
	
	queue_free()
