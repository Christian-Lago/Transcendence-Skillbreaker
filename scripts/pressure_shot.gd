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

func setup(dir, charge, spd, d_min, d_max, f_start, f_end):
	# Guardamos todos los parámetros
	# Save all parameters
	direction     = dir
	charge_pct    = charge
	speed         = spd
	dmg_min       = d_min
	dmg_max       = d_max
	falloff_start = f_start
	falloff_end   = f_end
	origin        = global_position

func _physics_process(delta):
	# Mover el proyectil
	# Move the projectile
	position += direction * speed * delta

	# Destruir si supera el rango máximo
	# Destroy if out of range
	if global_position.distance_to(origin) > falloff_end:
		queue_free()

func _calc_damage(dist: float) -> float:
	# Calcular daño según carga y distancia
	# Calculate damage by charge and distance
	var base = lerp(dmg_min, dmg_max, charge_pct)
	if dist <= falloff_start:
		return base
	var t = clamp((dist - falloff_start) / (falloff_end - falloff_start), 0.0, 1.0)
	var final_damage = lerp(base, base * 0.2, t)

	# Mostrar daño en consola para verificar
	# Show damage in console to verify
	print("Daño / Damage: ", final_damage)

	return final_damage
