extends Area2D

# Nombre de la habilidad que contiene este orbe
# Skill name contained in this orb
@export var skill_id: String = "fire_snake"
@export var skill_name: String = "Serpiente de Fuego"

func _ready():
	# Conectar señal de colisión
	# Connect collision signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si el jugador toca el orbe, mostrar pantalla de robo
	# If player touches orb, show steal screen
	if body.is_in_group("player"):
		var steal_screen = preload("res://scenes/skill_steal.tscn").instantiate()
		steal_screen.setup(skill_id, skill_name)
		get_parent().add_child(steal_screen)
		queue_free()
