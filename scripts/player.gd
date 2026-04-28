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
# Vida máxima
# Max health
const HEALTH_MAX = 100.0
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
# Vida actual
# Current health
var health = 100.0
# Temporizador del cooldown
# Cooldown timer
var ult_cooldown_timer = 0.0
# Temporizador de carga
# Charge timer
var charge_timer = 0.0
# Si está cargando
# If charging
var is_charging = false

signal health_changed(current: float, maximum: float)
signal energy_changed(current: float, maximum: float)
signal player_died

func _physics_process(delta):
	# Gravedad
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	# Regenerar energía con el tiempo, emitir señal solo si cambia
	# Regenerate energy over time, emit signal only if it changes
	var prev_energy = energy
	energy = min(ENERGY_MAX, energy + ENERGY_REGEN * delta)
	if energy != prev_energy:
		emit_signal("energy_changed", energy, ENERGY_MAX)
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
	print("Disparando / Firing")  # ← añade esta línea
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
	# Gastar energía y emitir señal
	# Spend energy and emit signal
	energy -= ENERGY_COST
	emit_signal("energy_changed", energy, ENERGY_MAX)
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
				print("Ultimate: muerte instantánea a nivel / instant kill level: ", body.enemy_level)
				body.die()
			else:
				var damage = 80.0
				print("Ultimate: daño a nivel / damage to level: ", body.enemy_level, " | Daño / Damage: ", damage)
				body.take_damage(damage)
	print("Ultimate activado / Ultimate activated")
	_screen_shake(0.3, 15.0)

func take_damage(damage: float):
	health = max(0.0, health - damage)
	emit_signal("health_changed", health, HEALTH_MAX)
	if health <= 0:
		emit_signal("player_died")
		print("Jugador muerto / Player dead")
		# Instanciar game over
		# Instantiate game over
		var game_over = preload("res://scenes/game_over.tscn").instantiate()
		get_parent().add_child(game_over)

func _screen_shake(duration: float, strength: float):
	var camera = get_node("Camera2D")
	var timer = 0.0
	while timer < duration:
		# Comprobar que el nodo sigue en escena
		# Check node is still in scene
		if not is_inside_tree():
			return
		camera.offset = Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		timer += get_process_delta_time()
		await get_tree().process_frame
	camera.offset = Vector2.ZERO
