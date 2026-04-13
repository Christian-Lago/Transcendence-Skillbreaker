extends Area2D

# Dirección de movimiento
# Movement direction
var direction: Vector2 = Vector2.ZERO

# Velocidad y daño
# Speed and damage
var speed: float = 400.0
var damage: float = 15.0

# Origen para calcular rango máximo
# Origin for max range calculation
var origin: Vector2

const MAX_RANGE = 800.0

func setup(dir: Vector2, dmg: float):
	direction = dir
	damage = dmg

func _ready():
	# Guardar origen una vez en escena
	# Save origin once in scene
	origin = global_position
	# Conectar señal de colisión
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	# Destruir si supera el rango máximo
	# Destroy if out of max range
	if global_position.distance_to(origin) > MAX_RANGE:
		queue_free()

func _on_body_entered(body):
	# Dañar al jugador si pertenece al grupo "player"
	# Damage player if in group "player"
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
