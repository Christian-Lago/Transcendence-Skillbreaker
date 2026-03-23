extends CharacterBody2D

# Velocidad de movimiento
# Movement speed
const SPEED    = 300.0

# Velocidad de salto
# Jump velocity
const JUMP_VEL = -600.0

# Gravedad
# Gravity
const GRAVITY  = 1200.0

# Daño mínimo y máximo del golpe
# Min and max damage of the shot
const DMG_MIN = 30.0
const DMG_MAX = 150.0

# Tiempo máximo de carga
# Max charge time
const CHARGE_TIME = 1.5

# Distancia de falloff
# Falloff distance
const FALLOFF_START = 200.0
const FALLOFF_END   = 600.0

# Velocidad del proyectil
# Projectile speed
const PROJ_SPEED = 900.0

# Temporizador de carga
# Charge timer
var charge_timer = 0.0

# Si está cargando
# If charging
var is_charging = false

func _physics_process(delta):
	# Gravedad
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Salto
	# Jump
	if Input.is_action_just_pressed("Up") and is_on_floor():
		velocity.y = JUMP_VEL

	# Movimiento horizontal
	# Horizontal movement
	var dir = Input.get_axis("Left", "Right")
	velocity.x = dir * SPEED

	# Carga del golpe
	# Shot charge
	if is_charging:
		charge_timer = min(charge_timer + delta, CHARGE_TIME)

	# Iniciar carga
	# Start charge
	if Input.is_action_just_pressed("Attack"):
		is_charging = true
		charge_timer = 0.0

	# Disparar al soltar
	# Fire on release
	if Input.is_action_just_released("Attack"):
		_fire_pressure_shot()
		is_charging = false

	move_and_slide()

func _fire_pressure_shot():
	# Calcular dirección hacia el ratón
	# Calculate direction towards mouse
	var direction = (get_global_mouse_position() - global_position).normalized()

	# Calcular porcentaje de carga
	# Calculate charge percentage
	var charge_pct = charge_timer / CHARGE_TIME

	# Instanciar el proyectil
	# Instantiate the projectile
	var proj = preload("res://scenes/pressure_shot.tscn").instantiate()
	proj.global_position = global_position
	proj.setup(direction, charge_pct, PROJ_SPEED, DMG_MIN, DMG_MAX, FALLOFF_START, FALLOFF_END)
	get_parent().add_child(proj)
