extends StaticBody2D

# Vida del suelo rompible
# Breakable floor health
@export var health: float = 100.0
const HEALTH_MAX: float = 100.0

# Temporizador de parpadeo al recibir daño
# Blink timer on damage
var blink_timer: float = 0.0

func _physics_process(delta):
	if blink_timer > 0:
		blink_timer -= delta

func take_damage(damage: float):
	# Recibir daño del proyectil del jugador
	# Receive damage from player projectile
	health -= damage
	blink_timer = 0.3
	print("Suelo rompible vida / Breakable floor health: ", health)
	if health <= 0:
		_break()

func _break():
	# Romper el suelo y abrir el paso
	# Break the floor and open the path
	print("Suelo roto / Floor broken")
	queue_free()
