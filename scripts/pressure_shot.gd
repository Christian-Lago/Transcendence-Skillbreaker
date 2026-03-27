extends Area2D

# Dirección del proyectil
# Projectile direction
var direction: Vector2

# Velocidad
# Speed
var speed: float

# Daño mínimo y máximo
# Min and max damage
var dmg_min: float
var dmg_max: float

# Distancia de falloff
# Falloff distance
var falloff_start: float
var falloff_end: float

# Porcentaje de carga
# Charge percentage
var charge_pct: float

# Posición de origen
# Origin position
var origin: Vector2

# Objetivo al que perseguir
# Target to follow
var target = null

# Velocidad de giro del péndulo
# Pendulum turn speed
var pendulum_angle = 0.0
var pendulum_speed = 8.0
var pendulum_amplitude = 0.4

func setup(dir, charge, spd, d_min, d_max, f_start, f_end):
	# Guardar parámetros
	# Save parameters
	direction     = dir
	charge_pct    = charge
	speed         = spd
	dmg_min       = d_min
	dmg_max       = d_max
	falloff_start = f_start
	falloff_end   = f_end
	origin        = global_position

	# Escalar según carga
	# Scale based on charge
	var min_scale = 0.5
	var max_scale = 2.0
	var final_scale = lerp(min_scale, max_scale, charge_pct)
	scale = Vector2(final_scale, final_scale)
	
func _ready():
	# Buscar objetivo una vez en escena
	# Find target once in scene
	_find_target()

func _find_target():
	# Buscar todos los enemigos en la escena
	# Find all enemies in scene
	var enemies = get_tree().get_nodes_in_group("enemy")
	var best = null
	var best_dot = 0.6  # Ángulo del cono (~53 grados)

	for e in enemies:
		var to_enemy = (e.global_position - global_position).normalized()
		var dot = direction.dot(to_enemy)
		if dot > best_dot:
			best_dot = dot
			best = e

	target = best

func _physics_process(delta):
	# Si tiene objetivo, perseguir con péndulo
	# If has target, follow with pendulum
	if target and is_instance_valid(target):
		var to_target = (target.global_position - global_position).normalized()
		pendulum_angle += pendulum_speed * delta
		var pendulum_offset = sin(pendulum_angle) * pendulum_amplitude
		var perp = Vector2(-to_target.y, to_target.x)
		direction = (to_target + perp * pendulum_offset).normalized()

	# Mover el proyectil
	# Move projectile
	position += direction * speed * delta

	# Comprimir al acercarse al objetivo
	# Compress when close to target
	if target and is_instance_valid(target):
		var dist_to_target = global_position.distance_to(target.global_position)
		if dist_to_target < 100:
			var compress = dist_to_target / 100.0
			scale = Vector2(compress, compress) * lerp(0.5, 2.0, charge_pct)

	# Destruir si supera el rango máximo
	# Destroy if out of range
	if global_position.distance_to(origin) > falloff_end:
		queue_free()

func _on_body_entered(body):
	# Comprobar si el cuerpo es un enemigo
	# Check if body is an enemy
	if body.has_method("take_damage"):
		var dist = global_position.distance_to(origin)
		var damage = _calc_damage(dist)
		body.take_damage(damage)

		# Registrar kill si el enemigo muere
		# Register kill if enemy dies
		if body.health <= 0:
			SkillManager.register_kill("pressure")

		queue_free()

func _calc_damage(dist: float) -> float:
	# Calcular daño según carga y distancia
	# Calculate damage by charge and distance
	var base = lerp(dmg_min, dmg_max, charge_pct)
	if dist <= falloff_start:
		return base
	var t = clamp((dist - falloff_start) / (falloff_end - falloff_start), 0.0, 1.0)
	var final_damage = lerp(base, base * 0.2, t)
	print("Daño / Damage: ", final_damage)
	return final_damage
