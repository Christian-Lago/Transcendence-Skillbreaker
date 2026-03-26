extends CharacterBody2D
# Velocidad de movimiento
# Movement speed
const SPEED = 300.0
# Velocidad de salto
# Jump velocity
const JUMP_VEL = -600.0
# Gravedad
# Gravity
const GRAVITY = 1200.0
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
const FALLOFF_END = 600.0
# Velocidad del proyectil
# Projectile speed
const PROJ_SPEED = 900.0
# Energía máxima
# Max energy
const ENERGY_MAX = 100.0
# Coste del ultimate
# Ultimate cost
const ENERGY_COST = 0.0
# Regeneración de energía por segundo
# Energy regen per second
const ENERGY_REGEN = 5.0
# Energía ganada por kill
# Energy gained per kill
const ENERGY_PER_KILL = 10.0
# Radio del ultimate
# Ultimate radius
const ULT_RADIUS = 500.0
# Cooldown del ultimate
# Ultimate cooldown
const ULT_COOLDOWN = 0.0
# Energía actual
# Current energy
var energy = 100.0
# Temporizador del cooldown
# Cooldown timer
var ult_cooldown_timer = 0.0
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
	# Regenerar energía con el tiempo
	# Regenerate energy over time
	energy = min(ENERGY_MAX, energy + ENERGY_REGEN * delta)
	# Reducir cooldown del ultimate
	# Reduce ultimate cooldown
	if ult_cooldown_timer > 0:
		ult_cooldown_timer -= delta
	# Activar ultimate
	# Activate ultimate
	if Input.is_action_just_pressed("Ultimate"):
		_use_ultimate()
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
	var aim_direction = (get_global_mouse_position() - global_position).normalized()
	# Calcular porcentaje de carga
	# Calculate charge percentage
	var charge_pct = charge_timer / CHARGE_TIME
	# Instanciar el proyectil
	# Instantiate the projectile
	var proj = preload("res://scenes/pressure_shot.tscn").instantiate()
	proj.global_position = global_position
	proj.setup(aim_direction, charge_pct, PROJ_SPEED, DMG_MIN, DMG_MAX, FALLOFF_START, FALLOFF_END)
	get_parent().add_child(proj)
	
func _use_ultimate():
	# Comprobar si hay suficiente energía y cooldown
	# Check if enough energy and cooldown
	if energy < ENERGY_COST:
		return
	# Gastar energía y activar cooldown
	# Spend energy and activate cooldown
	energy -= ENERGY_COST
	# Detectar enemigos en radio y matarlos
	# Detect enemies in radius and kill them
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = ULT_RADIUS
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 2
	var results = space.intersect_shape(query)
	for r in results:
		var body = r["collider"]
		if body.has_method("take_damage"):
			var diff = body.enemy_level - 90
			if diff <= -10:
				# Enemigo 10+ niveles por debajo, muerte instantánea
				# Enemy 10+ levels below, instant kill
				print("Ultimate: muerte instantánea a nivel / instant kill level: ", body.enemy_level)
				body.die()
			else:
				# Enemigo cercano en nivel, solo daño
				# Enemy close in level, damage only
				var damage = 80.0
				print("Ultimate: daño a nivel / damage to level: ", body.enemy_level, " | Daño / Damage: ", damage)
				body.take_damage(damage)
	print("Ultimate activado / Ultimate activated")
